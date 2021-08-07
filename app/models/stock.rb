class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  def self.new_lookup(ticker_symbol)
    client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                   connect_timeout: 300)
    pulled_stock = TwelvedataRuby.client.quote(symbol: ticker_symbol).parsed_body
    unless pulled_asset[:code].present?
      new(ticker: ticker_symbol, name: pulled_asset[:name],
          last_price: pulled_asset[:close].to_d, exchange: pulled_asset[:exchange])
    end
  end

  def self.check_db(ticker_symbol)
    where(ticker: ticker_symbol).first
  end

  def self.update_prices
    all.each do |s|
      next unless s.updated_at < 10.minutes.ago

      client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                     connect_timeout: 300)
      pulled_stock = TwelvedataRuby.client.quote(symbol: s.ticker).parsed_body
      s.last_price = pulled_stock[:close].to_d
      s.exchange = pulled_stock[:exchange]
      s.save
      sleep(8) unless @stocks.last
    end

    def self.update_price(_ticker_symbol)
      if s = where(ticker: _ticker_symbol).first && !(s.updated_at < 10.minutes.ago)
        client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                       connect_timeout: 300)
        pulled_stock = TwelvedataRuby.client.quote(symbol: _ticker_symbol).parsed_body
        s.last_price = pulled_stock[:close].to_d
        s.save
      end
    end
  end
end
