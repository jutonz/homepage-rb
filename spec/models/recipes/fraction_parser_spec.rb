require "rails_helper"

RSpec.describe Recipes::FractionParser do
  describe ".parse" do
    it "returns [nil, nil] for blank input" do
      expect(described_class.parse("")).to eq([nil, nil])
      expect(described_class.parse(nil)).to eq([nil, nil])
      expect(described_class.parse("   ")).to eq([nil, nil])
    end

    it "parses whole numbers" do
      expect(described_class.parse("2")).to eq([2, 1])
      expect(described_class.parse("10")).to eq([10, 1])
      expect(described_class.parse("0")).to eq([0, 1])
    end

    it "parses simple fractions" do
      expect(described_class.parse("1/2")).to eq([1, 2])
      expect(described_class.parse("3/4")).to eq([3, 4])
      expect(described_class.parse("2/3")).to eq([2, 3])
    end

    it "parses mixed numbers" do
      expect(described_class.parse("1 1/2")).to eq([3, 2])
      expect(described_class.parse("2 3/4")).to eq([11, 4])
      expect(described_class.parse("3 2/5")).to eq([17, 5])
    end

    it "parses decimals" do
      expect(described_class.parse("0.5")).to eq([1, 2])
      expect(described_class.parse("0.25")).to eq([1, 4])
      expect(described_class.parse("0.75")).to eq([3, 4])
      expect(described_class.parse("1.5")).to eq([3, 2])
      expect(described_class.parse("2.25")).to eq([9, 4])
    end

    it "handles common decimal approximations" do
      expect(described_class.parse("0.33")).to eq([1, 3])
      expect(described_class.parse("0.333")).to eq([1, 3])
      expect(described_class.parse("0.3333")).to eq([1, 3])
      expect(described_class.parse("0.67")).to eq([2, 3])
      expect(described_class.parse("0.667")).to eq([2, 3])
      expect(described_class.parse("0.6667")).to eq([2, 3])
    end

    it "handles zero denominator" do
      expect(described_class.parse("1/0")).to eq([nil, nil])
    end

    it "handles invalid formats" do
      expect(described_class.parse("abc")).to eq([nil, nil])
      expect(described_class.parse("1/2/3")).to eq([nil, nil])
      expect(described_class.parse("1 2")).to eq([nil, nil])
      expect(described_class.parse("1/")).to eq([nil, nil])
      expect(described_class.parse("/2")).to eq([nil, nil])
    end

    it "handles whitespace" do
      expect(described_class.parse(" 1/2 ")).to eq([1, 2])
      expect(described_class.parse(" 2 1/3 ")).to eq([7, 3])
    end
  end
end
