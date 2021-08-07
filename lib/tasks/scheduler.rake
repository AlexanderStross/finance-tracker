# 1.upto(9) do |_iteration|
#   start_time = DateTime.now
#   Services::MyService.call
#   end_time = DateTime.now
#   wait_time = 60 - ((end_time - start_time) * 24 * 60 * 60).to_i
#   sleep wait_time if wait_time > 0
# end
task update_tickers: :environment do
  Stock.each do |stock|
<<<<<<< HEAD
    stock.last_price = stock.check_db(stock.ticker_symbol)
=======
    stock.last_price = stock..check_db(stock.ticker_symbol)
>>>>>>> 4b3547f7d4c40a0c2d072e28035e864999c0743a
  end
end
