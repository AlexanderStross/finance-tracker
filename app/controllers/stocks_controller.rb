class StocksController < ApplicationController
  def search
    if params[:stock].present?
      @stock = Stock.new_lookup(params[:stock])
      if @stock
        respond_to do |format|
          format.js { render partial: 'users/result' }
        end
      else
        respond_to do |format|
          flash.now[:alert] = 'Please enter a valid symbol to search'
          format.js { render partial: 'users/result' }
        end
      end
    else
      respond_to do |format|
        flash.now[:alert] = 'Please enter a symbol to search'
        format.js { render partial: 'users/result' }
      end
    end
  end

  def update_prices_now
    @user = current_user
    @tracked_stocks = current_user.stocks
    @stocks = Stock.all
    td_stock = []
    cur_key = 1
    last_key = 10
    if @stocks
      @stocks.each do |stock|
        logger.debug "#{stock.ticker} updated at: #{stock.updated_at} ten minutes ago was #{10.minutes.ago}"
        logger.debug "#{stock.ticker} updated at vs now: #{Time.now - (stock.updated_at + 10.minutes)}"
        next unless stock.updated_at + 3.minutes < Time.now

        key = ('api_key' + cur_key.to_s).to_sym
        if cur_key < last_key
          cur_key += 1
        else
          cur_key = 1
        end

        logger.debug "Made it into block key: #{key}"
        client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[key],
                                       connect_timeout: 300)
        td_stock = TwelvedataRuby.client.quote(symbol: stock.ticker).parsed_body
        if td_stock[:code]
          logger.debug 'API Error Detected'
          flash.now[:alert] = "Status: #{td_stock[:status]}, Code: #{td_stock[:code]}, Message: #{td_stock[:message]}"
        end
        break if td_stock[:code]

        logger.debug td_stock.to_s
        logger.debug "#{stock.ticker} price saved in database: #{stock.last_price} remote price: #{td_stock[:close].to_d}"
        logger.debug "#{stock.ticker} Price Changed? : #{stock.last_price != td_stock[:close].to_d}"
        stock.update(delta: (td_stock[:close].to_d - stock.last_price) / stock.last_price,
                     last_price: td_stock[:close].to_d, exchange: td_stock[:exchange])
        # sleep(2) unless stock == @stocks.last
      end
      respond_to do |format|
        flash.now[:notice] = 'Prices updated!' unless td_stock[:code]
        format.js { render partial: 'stocks/update_list' }
      end
    end
  end

  private

  def market_closed(market); end
end
