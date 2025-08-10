module Recipes
  class FractionParser
    def self.parse(input)
      return [nil, nil] if input.blank?

      input = input.to_s.strip

      # Handle whole numbers
      if /^\d+$/.match?(input)
        return [input.to_i, 1]
      end

      # Handle decimals
      if /^\d*\.\d+$/.match?(input)
        return parse_decimal(input.to_f)
      end

      # Handle mixed numbers (e.g., "2 1/2")
      if (match = /^(\d+)\s+(\d+)\/(\d+)$/.match(input))
        whole, num, denom = match.captures.map(&:to_i)
        return [whole * denom + num, denom]
      end

      # Handle simple fractions (e.g., "1/2")
      if (match = /^(\d+)\/(\d+)$/.match(input))
        num, denom = match.captures.map(&:to_i)
        return [num, denom] if denom != 0
      end

      # Invalid format
      [nil, nil]
    end

    private_class_method def self.parse_decimal(decimal)
      return [decimal.to_i, 1] if decimal == decimal.to_i

      # Convert decimal to fraction using continued fractions
      tolerance = 1e-10
      max_denominator = 10000

      # Find the best rational approximation
      num, denom = rationalize(decimal, tolerance, max_denominator)
      [num, denom]
    end

    private_class_method def self.rationalize(decimal, tolerance, max_denominator)
      return [decimal.to_i, 1] if decimal == decimal.to_i

      # Use the continued fraction algorithm
      original = decimal
      a = decimal.floor
      remainder = decimal - a

      if remainder < tolerance
        return [a, 1]
      end

      # Start with convergents
      h_prev2, h_prev1 = 0, 1
      k_prev2, k_prev1 = 1, 0

      loop do
        remainder = 1.0 / remainder
        a = remainder.floor
        remainder -= a

        h_curr = a * h_prev1 + h_prev2
        k_curr = a * k_prev1 + k_prev2

        break if k_curr > max_denominator

        # Check if we have a good enough approximation
        if (original - h_curr.to_f / k_curr).abs < tolerance
          return [h_curr, k_curr]
        end

        break if remainder < tolerance

        h_prev2, h_prev1 = h_prev1, h_curr
        k_prev2, k_prev1 = k_prev1, k_curr
      end

      # Fallback for common decimals
      case decimal
      when 0.25 then [1, 4]
      when 0.5 then [1, 2]
      when 0.75 then [3, 4]
      when 0.33, 0.333, 0.3333 then [1, 3]
      when 0.67, 0.667, 0.6667 then [2, 3]
      else
        # Default approximation
        denominator = 100
        numerator = (decimal * denominator).round
        gcd = numerator.gcd(denominator)
        [numerator / gcd, denominator / gcd]
      end
    end
  end
end
