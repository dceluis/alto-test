require_relative 'receipt_parser'

describe ReceiptParser do
  describe ".call" do
    it "parses input 1 correctly" do
      input = [
        "2 book at 12.49",
        "1 music CD at 14.99",
        "1 chocolate bar at 0.85"
      ]

      expect(ReceiptParser.parse(input.join("\n")).print).to eq(
        "2 book: 24.98\n1 music CD: 16.49\n1 chocolate bar: 0.85\nSales Taxes: 1.50\nTotal: 42.32"
      )
    end

    it "parses input 2 correctly" do
      input = [
        "1 imported box of chocolates at 10.00",
        "1 imported bottle of perfume at 47.50"
      ]

      expect(ReceiptParser.parse(input.join("\n")).print).to eq(
        "1 imported box of chocolates: 10.50\n1 imported bottle of perfume: 54.65\nSales Taxes: 7.65\nTotal: 65.15"
      )
    end

    it "parses input 3 correctly" do
      input = [
        "1 imported bottle of perfume at 27.99",
        "1 bottle of perfume at 18.99",
        "1 packet of headache pills at 9.75",
        "3 imported boxes of chocolates at 11.25"
      ]

      expect(ReceiptParser.parse(input.join("\n")).print).to eq(
        "1 imported bottle of perfume: 32.19\n1 bottle of perfume: 20.89\n1 packet of headache pills: 9.75\n3 imported box of chocolates: 35.45\nSales Taxes: 7.80\nTotal: 98.28"
      )
    end
  end
end
