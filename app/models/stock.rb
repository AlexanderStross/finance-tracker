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
    Stock.where(ticker: ticker_symbol).first
  end

  def self.update_prices
    all.each do |s|
      client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                     connect_timeout: 300)
      pulled_stock = TwelvedataRuby.client.quote(symbol: s.ticker).parsed_body
      s.last_price = pulled_stock[:close].to_d
      s.save
      sleep(8)
    end
  end
end
