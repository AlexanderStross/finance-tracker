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
    if @stocks
      @stocks.each do |stock|
        logger.debug "#{stock.ticker} updated at: #{stock.updated_at} ten minutes ago was #{10.minutes.ago}"
        logger.debug "#{stock.ticker} updated at vs now: #{Time.now - (stock.updated_at + 10.minutes)}"
        next unless stock.updated_at + 10.minutes < Time.now

        logger.debug 'Made it into block'
        client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                       connect_timeout: 300)
        td_stock = TwelvedataRuby.client.quote(symbol: stock.ticker).parsed_body
        logger.debug td_stock.to_s
        logger.debug "#{stock.ticker} price saved in database: #{stock.last_price} remote price: #{td_stock[:close].to_d}"
        logger.debug "#{stock.ticker} Price Changed? : #{stock.last_price != td_stock[:close].to_d}"
        stock.update(last_price: td_stock[:close].to_d)
        # sleep(8) if stock != @stocks.last
      end
      respond_to do |format|
        flash.now[:success] = 'Prices updated!'
        format.js { render partial: 'stocks/update_list' }
      end
    end
  end
end
