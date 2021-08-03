class Stock < ApplicationRecord
  def self.new_lookup(ticker_symbol)
    client = TwelvedataRuby.client(apikey: '64a701b0e89d4625ba108288748893f8', connect_timeout: 300)
    TwelvedataRuby.client.price(symbol: ticker_symbol).parsed_body[:price].to_d
  end
end
