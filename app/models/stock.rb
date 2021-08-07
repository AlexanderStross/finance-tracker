class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  def self.new_lookup(ticker_symbol)
    client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                   connect_timeout: 300)
    remote_stock = TwelvedataRuby.client.quote(symbol: ticker_symbol).parsed_body
    unless remote_stock[:code].present?
      new(ticker: ticker_symbol, name: remote_stock[:name],
          last_price: remote_stock[:close].to_d, exchange: remote_stock[:exchange])
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
      remote_stock = TwelvedataRuby.client.quote(symbol: s.ticker).parsed_body
      s.last_price = remote_stock[:close].to_d
      s.exchange = remote_stock[:echange]
      s.save
      sleep(15)
    end

    def self.update_price(_ticker_symbol)
      if s = where(ticker: _ticker_symbol).first && !(s.updated_at < 10.minutes.ago)
        client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                       connect_timeout: 300)
        remote_stock = TwelvedataRuby.client.quote(symbol: _ticker_symbol).parsed_body
        s.last_price = remote_stock[:close].to_d
        s.save
      end
    end
  end
end
