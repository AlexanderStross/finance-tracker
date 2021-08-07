class AddExchangeToStock < ActiveRecord::Migration[6.1]
  def change
    add_column :stocks, :exchange, :string
  end
end
