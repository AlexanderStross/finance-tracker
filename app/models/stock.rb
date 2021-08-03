class Stock < ApplicationRecord
  def self.new_lookup(ticker_symbol)
    client = TwelvedataRuby.client(apikey: 'Rails.application.credentials.twelvedata_client[:api_key]',
                                   connect_timeout: 300)
    TwelvedataRuby.client.price(symbol: ticker_symbol).parsed_body[:price].to_d
  end
end
