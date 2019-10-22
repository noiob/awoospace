# frozen_string_literal: true

class StatusLengthValidator < ActiveModel::Validator
  MAX_CHARS = (ENV['MAX_TOOT_CHARS'] || 500).to_i

  def validate(status)
    status.errors.add(:text, "hard limit of 16k exceeded") if status.text.length > 16384
    status.errors.add(:text, "CW can't be longer than 500 characters") if status.spoiler_text.length > 500
    return unless status.spoiler_text.blank?
    return unless status.local? && !status.reblog?

    @status = status
    status.errors.add(:text, I18n.t('statuses.over_character_limit', max: MAX_CHARS)) if too_long?
  end

  private

  def too_long?
    countable_length > MAX_CHARS
  end

  def countable_length
    total_text.mb_chars.grapheme_length
  end

  def total_text
    [@status.spoiler_text, countable_text].join
  end

  def countable_text
    return '' if @status.text.nil?

    @status.text.dup.tap do |new_text|
      new_text.gsub!(FetchLinkCardService::URL_PATTERN, 'x' * 23)
      new_text.gsub!(Account::MENTION_RE, '@\2')
    end
  end
end
