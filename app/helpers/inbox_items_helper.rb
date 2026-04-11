module InboxItemsHelper
  def render_email_text(raw_body)
    lines = raw_body.to_s.lines.map(&:rstrip)

    # Drop the "---------- Forwarded message ---------" header block
    # (everything up to and including the first blank line after it)
    if (fwd_idx = lines.index { |l| l.match?(/^-{5,}\s*Forwarded message/i) })
      blank_after = lines.index.with_index { |l, i| i > fwd_idx && l.strip.empty? }
      lines = lines[(blank_after || fwd_idx) + 1..]&.drop_while { |l| l.strip.empty? } || []
    end

    # Drop noise lines
    lines.reject! do |l|
      l.match?(/^\[image:/i) ||          # [image: Booking.com]
        l.match?(/^<https?:/) ||          # <https://...>
        l.match?(/^https?:\/\/\S+$/)      # bare URLs on their own line
    end

    # Collapse 3+ consecutive blank lines to 2
    text = lines.join("\n").gsub(/\n{3,}/, "\n\n").strip

    # Split into paragraphs and render each
    paragraphs = text.split(/\n{2,}/)
    safe_paras = paragraphs.map do |para|
      lines_in_para = para.lines.map do |line|
        line = CGI.escapeHTML(line.rstrip)
        # *bold* → <strong>
        line = line.gsub(/\*([^*]+)\*/, '<strong>\1</strong>')
        # inline URLs → strip them
        line = line.gsub(/&lt;https?:[^&]*&gt;/, "").gsub(/https?:\/\/\S+/, "")
        line
      end.reject { |l| l.strip.empty? }
      next if lines_in_para.empty?

      content = lines_in_para.join("<br>")

      # Style: separator lines (---), section headers (all caps / ends with :)
      first = lines_in_para.first.gsub(/<[^>]+>/, "").strip
      css = if first.match?(/^[-=]{3,}$/)
        "border-t border-base-300 pt-3 mt-1"
      elsif first == first.upcase && first.length > 3 && !first.match?(/\d/)
        "font-semibold text-base-content/80 mt-2"
      else
        ""
      end

      "<p class=\"#{css}\">#{content}</p>"
    end.compact

    safe_paras.join.html_safe
  end
end
