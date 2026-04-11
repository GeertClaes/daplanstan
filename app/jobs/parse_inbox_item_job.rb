class ParseInboxItemJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  SYSTEM_PROMPT = <<~PROMPT
    You are a travel assistant that extracts structured information from forwarded booking confirmation emails.
    Analyse the email and extract any of the following that are present:
    - Flight, train, ferry, bus or car travel legs
    - Accommodation check-ins
    - Other bookings (tours, car hire, restaurants, tickets, etc.)
    - Places of interest mentioned (restaurants, attractions, activities)

    Be conservative: only extract information that is clearly stated in the email.
    For dates and times, use ISO 8601 format (YYYY-MM-DDTHH:MM:SS). If no year is given, infer from context.
    For prices, extract the total amount paid and the currency code (e.g. EUR, USD, GBP).
    If a piece of information is not present, omit the field entirely rather than guessing.
  PROMPT

  ANTHROPIC_TOOLS = [
    {
      name: "record_travel_data",
      description: "Record structured travel data extracted from the email",
      input_schema: {
        type: "object",
        properties: {
          travel_legs: {
            type: "array",
            items: {
              type: "object",
              properties: {
                mode:                { type: "string", enum: %w[plane train ferry bus car] },
                departure_location:  { type: "string" },
                arrival_location:    { type: "string" },
                departure_datetime:  { type: "string", description: "ISO 8601" },
                arrival_datetime:    { type: "string", description: "ISO 8601" },
                carrier:             { type: "string" },
                booking_reference:   { type: "string" },
                total_price:         { type: "number", description: "Total price paid" },
                currency:            { type: "string", description: "ISO 4217 currency code, e.g. EUR" },
                notes:               { type: "string" }
              },
              required: %w[mode departure_location arrival_location departure_datetime arrival_datetime]
            }
          },
          accommodations: {
            type: "array",
            items: {
              type: "object",
              properties: {
                name:                { type: "string" },
                address:             { type: "string" },
                check_in:            { type: "string", description: "ISO 8601 date or datetime" },
                check_out:           { type: "string", description: "ISO 8601 date or datetime" },
                confirmation_number: { type: "string" },
                total_price:         { type: "number", description: "Total price paid" },
                currency:            { type: "string", description: "ISO 4217 currency code, e.g. EUR" },
                notes:               { type: "string" }
              },
              required: %w[name check_in check_out]
            }
          },
          bookings: {
            type: "array",
            items: {
              type: "object",
              properties: {
                booking_type:           { type: "string", description: "e.g. tour, car_hire, restaurant, ticket, activity" },
                provider:               { type: "string" },
                location:               { type: "string" },
                confirmation_reference: { type: "string" },
                datetime:               { type: "string", description: "ISO 8601 start datetime" },
                end_datetime:           { type: "string", description: "ISO 8601 end datetime" },
                total_price:            { type: "number", description: "Total price paid" },
                currency:               { type: "string", description: "ISO 4217 currency code, e.g. EUR" },
                notes:                  { type: "string" }
              },
              required: %w[booking_type provider]
            }
          },
          shortlist_items: {
            type: "array",
            items: {
              type: "object",
              properties: {
                name:     { type: "string" },
                category: { type: "string", enum: %w[eat see do scout stay] },
                address:  { type: "string" },
                notes:    { type: "string" }
              },
              required: %w[name category]
            }
          }
        }
      }
    }
  ]

  def perform(inbox_item_id)
    inbox_item = InboxItem.find_by(id: inbox_item_id)
    return unless inbox_item

    prompt = build_prompt(inbox_item)
    data   = parse_with_anthropic(prompt)

    inbox_item.update!(parsed_data: data, parse_status: :parsed)

  rescue => e
    Rails.logger.error "[ParseInboxItemJob] Failed for inbox_item #{inbox_item_id}: #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    inbox_item&.update(parse_status: :failed)
  end

  private

  def build_prompt(inbox_item)
    body = inbox_item.raw_body.to_s.truncate(4000, omission: "\n[... email truncated ...]")
    <<~MSG
      Trip: #{inbox_item.trip.title}
      From: #{inbox_item.from_name.presence || inbox_item.from_email}
      Subject: #{inbox_item.subject}

      #{body}
    MSG
  end

  def parse_with_anthropic(prompt)
    client   = Anthropic::Client.new
    response = client.messages.create(
      model:      "claude-haiku-4-5-20251001",
      max_tokens: 2048,
      system:     SYSTEM_PROMPT,
      tools:      ANTHROPIC_TOOLS,
      messages:   [ { role: "user", content: prompt } ]
    )

    tool_use = response.content.find { |block| block.type == :tool_use }
    tool_use ? tool_use.input.deep_stringify_keys : {}
  end
end
