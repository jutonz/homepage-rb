class FractionFormatter
  UNICODE_FRACTIONS = {
    [1, 2] => "½",
    [1, 3] => "⅓",
    [2, 3] => "⅔",
    [1, 4] => "¼",
    [3, 4] => "¾",
    [1, 5] => "⅕",
    [2, 5] => "⅖",
    [3, 5] => "⅗",
    [4, 5] => "⅘",
    [1, 6] => "⅙",
    [5, 6] => "⅚",
    [1, 7] => "⅐",
    [1, 8] => "⅛",
    [3, 8] => "⅜",
    [5, 8] => "⅝",
    [7, 8] => "⅞",
    [1, 9] => "⅑",
    [1, 10] => "⅒"
  }.freeze

  def self.format(numerator, denominator, use_unicode: false)
    return "" if numerator.blank? || denominator.blank?
    return "" if denominator == 0

    # Handle zero
    return "0" if numerator == 0

    # Simplify the fraction
    gcd = numerator.gcd(denominator)
    num = numerator / gcd
    denom = denominator / gcd

    # Handle whole numbers
    return num.to_s if denom == 1

    # Handle mixed numbers
    if num > denom
      whole = num / denom
      remainder = num % denom

      if remainder == 0
        return whole.to_s
      else
        fraction_part = format_fraction_part(remainder, denom, use_unicode)
        return "#{whole} #{fraction_part}"
      end
    end

    # Handle proper fractions
    format_fraction_part(num, denom, use_unicode)
  end

  def self.format_decimal(numerator, denominator)
    return "" if numerator.blank? || denominator.blank?
    return "" if denominator == 0

    (numerator.to_f / denominator).round(2).to_s
  end

  private_class_method def self.format_fraction_part(numerator, denominator, use_unicode)
    if use_unicode && UNICODE_FRACTIONS.key?([numerator, denominator])
      UNICODE_FRACTIONS[[numerator, denominator]]
    else
      "#{numerator}/#{denominator}"
    end
  end
end
