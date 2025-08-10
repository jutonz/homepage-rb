require "rails_helper"
require Rails.root.join("lib", "fraction_formatter")

RSpec.describe FractionFormatter do
  describe ".format" do
    it "returns empty string for blank values" do
      expect(FractionFormatter.format(nil, nil)).to eq("")
      expect(FractionFormatter.format("", "")).to eq("")
      expect(FractionFormatter.format(1, nil)).to eq("")
      expect(FractionFormatter.format(nil, 2)).to eq("")
    end

    it "returns empty string for zero denominator" do
      expect(FractionFormatter.format(1, 0)).to eq("")
    end

    it 'returns "0" for zero numerator' do
      expect(FractionFormatter.format(0, 2)).to eq("0")
    end

    it "formats whole numbers" do
      expect(FractionFormatter.format(2, 1)).to eq("2")
      expect(FractionFormatter.format(10, 1)).to eq("10")
      expect(FractionFormatter.format(4, 2)).to eq("2")
    end

    it "formats proper fractions" do
      expect(FractionFormatter.format(1, 2)).to eq("1/2")
      expect(FractionFormatter.format(3, 4)).to eq("3/4")
      expect(FractionFormatter.format(2, 3)).to eq("2/3")
    end

    it "formats mixed numbers" do
      expect(FractionFormatter.format(3, 2)).to eq("1 1/2")
      expect(FractionFormatter.format(11, 4)).to eq("2 3/4")
      expect(FractionFormatter.format(17, 5)).to eq("3 2/5")
    end

    it "simplifies fractions" do
      expect(FractionFormatter.format(2, 4)).to eq("1/2")
      expect(FractionFormatter.format(6, 8)).to eq("3/4")
      expect(FractionFormatter.format(10, 15)).to eq("2/3")
    end

    it "handles improper fractions that simplify to whole numbers" do
      expect(FractionFormatter.format(8, 4)).to eq("2")
      expect(FractionFormatter.format(15, 3)).to eq("5")
    end

    describe "unicode formatting" do
      it "uses unicode fractions when available" do
        expect(FractionFormatter.format(1, 2, use_unicode: true)).to eq("½")
        expect(FractionFormatter.format(1, 4, use_unicode: true)).to eq("¼")
        expect(FractionFormatter.format(3, 4, use_unicode: true)).to eq("¾")
        expect(FractionFormatter.format(1, 3, use_unicode: true)).to eq("⅓")
        expect(FractionFormatter.format(2, 3, use_unicode: true)).to eq("⅔")
      end

      it "uses unicode for mixed numbers when possible" do
        expect(FractionFormatter.format(3, 2, use_unicode: true)).to eq("1 ½")
        expect(FractionFormatter.format(7, 4, use_unicode: true)).to eq("1 ¾")
      end

      it "falls back to regular format for unsupported fractions" do
        expect(FractionFormatter.format(3, 7, use_unicode: true)).to eq("3/7")
        expect(FractionFormatter.format(5, 9, use_unicode: true)).to eq("5/9")
      end
    end
  end

  describe ".format_decimal" do
    it "returns empty string for blank values" do
      expect(FractionFormatter.format_decimal(nil, nil)).to eq("")
      expect(FractionFormatter.format_decimal(1, nil)).to eq("")
      expect(FractionFormatter.format_decimal(nil, 2)).to eq("")
    end

    it "returns empty string for zero denominator" do
      expect(FractionFormatter.format_decimal(1, 0)).to eq("")
    end

    it "formats as decimal" do
      expect(FractionFormatter.format_decimal(1, 2)).to eq("0.5")
      expect(FractionFormatter.format_decimal(3, 4)).to eq("0.75")
      expect(FractionFormatter.format_decimal(1, 3)).to eq("0.33")
      expect(FractionFormatter.format_decimal(5, 2)).to eq("2.5")
    end
  end
end
