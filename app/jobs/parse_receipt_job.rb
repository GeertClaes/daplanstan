class ParseReceiptJob < ApplicationJob
  queue_as :default

  def perform(expense_id)
    expense = Expense.find_by(id: expense_id)
    return unless expense&.receipt&.attached?

    image_data   = expense.receipt.download
    base64_image = Base64.strict_encode64(image_data)
    content_type = expense.receipt.content_type

    client   = Anthropic::Client.new
    response = client.messages.create(
      model:      "claude-haiku-4-5-20251001",
      max_tokens: 512,
      messages:   [
        {
          role:    "user",
          content: [
            {
              type:   "image",
              source: { type: "base64", media_type: content_type, data: base64_image }
            },
            {
              type: "text",
              text: <<~PROMPT
                This is a receipt. Extract:
                - total amount (number only, no currency symbol)
                - currency code (e.g. EUR, USD, GBP)
                - merchant/vendor name
                - date (ISO 8601)
                - category: one of accommodation, food_drink, transport, activities, shopping, other

                Reply with JSON only, no explanation:
                {"amount": 12.50, "currency": "EUR", "description": "Merchant name", "expense_date": "2026-03-29", "category": "food_drink"}
              PROMPT
            }
          ]
        }
      ]
    )

    text = response.content.find { |b| b.type == :text }&.text.to_s
    json = JSON.parse(text.match(/\{.*\}/m)&.to_s || "{}")
    return if json.blank?

    updates = {
      amount:       json["amount"]       || expense.amount,
      currency:     json["currency"]     || expense.currency,
      description:  json["description"]  || expense.description,
      category:     json["category"]     || expense.category,
      expense_date: json["expense_date"] || expense.expense_date
    }.compact

    expense.update!(updates)
    Rails.logger.info "[ParseReceiptJob] Updated expense #{expense_id}: #{updates.inspect}"
  rescue => e
    Rails.logger.error "[ParseReceiptJob] Failed for expense #{expense_id}: #{e.message}"
  end
end
