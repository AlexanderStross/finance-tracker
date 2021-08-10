class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  def self.new_lookup(ticker_symbol)
    key = ('api_key' + rand(1..5).to_s).to_sym
    client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[key],
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

  def self.update_data
    cur_key = 1
    last_key = 5
    all.each do |s|
      next unless s.updated_at + 3.minutes < Time.now

      key = ('api_key' + cur_key.to_s).to_sym
      if cur_key < last_key
        cur_key += 1
      else
        cur_key = 1
      end
      client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[key],
                                     connect_timeout: 300)
      td_stock = TwelvedataRuby.client.quote(symbol: s.ticker).parsed_body
      if td_stock[:code]
        logger.debug 'API Error Detected'
        flash.now[:alert] = "Status: #{td_stock[:status]}, Code: #{td_stock[:code]}, Message: #{td_stock[:message]}"
      end
      break if td_stock[:code]

      s.delta = (td_stock[:close].to_d - s.last_price) / s.last_price if s.last_price.present? && s.last_price != 0
      s.last_price = td_stock[:close].to_d
      s.exchange = td_stock[:exchange]
      s.save
      sleep(15)
    end
    respond_to do |format|
      flash.now[:notice] = 'Prices updated!' unless td_stock[:code]
      format.js { render partial: 'stocks/update_list' }
    end
  end
end
