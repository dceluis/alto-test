require "bigdecimal"

class ReceiptParser
  IMPORT_TAX = 5
  BASIC_TAX = 10
  BASIC_TAX_EXEMPT = [:book, :food, :medical]

  CATEGORIZATIONS = {
    "book" => :book,
    "box of chocolates" => :food,
    "chocolate bar" => :food,
    "packet of headache pills" => :medical,
    "music CD" => :other,
    "perfume" => :other
  }

  SINGULARS_DICT = {
    "boxes" => "box"
  }

  attr_reader :items, :parsed

  def self.parse(str)
    items = str.lines.map(&:strip)
    new(items).parse
  end

  def initialize(items)
    @items = items
    @parsed = {}
  end

  def print
    result = []

    @parsed[:items].each do |item|
      result << "#{item[:amount]} #{item[:imported] ? "imported " : ""}#{item[:item]}: #{format_price(item[:price_cents] * item[:amount] + item[:tax_cents])}"
    end
    result << "Sales Taxes: #{format_price(@parsed[:total_tax_cents])}"
    result << "Total: #{format_price(@parsed[:total_price_cents])}"

    result.join("\n")
  end

  def parse
    parsed_lines = @items.map do |item|
      parse_line(item)
    end

    @parsed = {
      items: parsed_lines,
      total_tax_cents: parsed_lines.sum { |item| item[:tax_cents] },
      total_price_cents: parsed_lines.sum { |item| item[:price_cents] * item[:amount] + item[:tax_cents] }
    }

    self
  end

  private

  def parse_line(line)
    line = line.split(" ")
    amount = Integer(line.shift)
    imported = !(line.shift if line.first == "imported").nil?
    price_cents = (BigDecimal(line.pop) * 100).round

    line.pop if line.last == "at"

    container, _, item = line.join(" ").rpartition(" of ")

    item = "#{(container != "") ? singularize(container) + " of " : ""}#{item}"

    tax_cents = calculate_tax(item, price_cents, amount, imported)

    {
      amount: amount,
      imported: imported,
      item: item,
      price_cents: price_cents,
      tax_cents: tax_cents
    }
  end

  def singularize(word)
    SINGULARS_DICT[word] || word.gsub(/s$/, "")
  end

  def format_price(price_cents)
    "%.2f" % (price_cents.to_i / 100.0)
  end

  def calculate_tax(item, price_cents, amount, imported)
    final_rate = (imported ? IMPORT_TAX : 0) + (BASIC_TAX_EXEMPT.include?(CATEGORIZATIONS[item]) ? 0 : BASIC_TAX)
    tax = ((final_rate * price_cents * amount) / 100.0).round
    round_to_5(tax)
  end

  def round_to_5(n)
    5 * ((n + 4) / 5)
  end
end
