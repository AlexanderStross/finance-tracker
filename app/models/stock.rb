class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  def self.new_lookup(ticker_symbol)
    client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                   connect_timeout: 300)
    stock = TwelvedataRuby.client.quote(symbol: ticker_symbol).parsed_body
    new(ticker: ticker_symbol, name: stock[:name], last_price: price = stock[:close].to_d) unless stock[:code].present?
  end

  def self.check_db(ticker_symbol)
    stock = Stock.where(ticker: ticker_symbol).first
    if stock
      client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                     connect_timeout: 300)
      remote_stock = TwelvedataRuby.client.quote(symbol: ticker_symbol).parsed_body
      stock.last_price = remote_stock[:close].to_d
      stock.save
      stock
    end
  end
end
