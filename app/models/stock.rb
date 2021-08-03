class Stock < ApplicationRecord
  def self.new_lookup(ticker_symbol)
    client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                   connect_timeout: 300)
    stock = TwelvedataRuby.client.quote(symbol: ticker_symbol).parsed_body
    new(ticker: ticker_symbol, name: stock[:name], last_price: price = stock[:close].to_d) unless stock[:code].present?
  end
end
