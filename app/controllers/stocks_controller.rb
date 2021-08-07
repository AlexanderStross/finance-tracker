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
    @stocks = Stock.all

    if @stocks
      @stocks.each do |stock|
        next unless stock.updated_at < 10.minutes.ago

        client = TwelvedataRuby.client(apikey: Rails.application.credentials.twelvedata_client[:api_key],
                                       connect_timeout: 300)
        td_stock = TwelvedataRuby.client.quote(symbol: stock.ticker).parsed_body
        stock.update(last_price: td_stock[:close].to_d)
        sleep(15)
      end
      respond_to do |format|
        flash.now[:success] = 'Prices updated!'
        format.js { render partial: 'users/result' }
      end
    end
  end
end
