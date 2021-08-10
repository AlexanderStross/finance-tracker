class AddPercentChange < ActiveRecord::Migration[6.1]
  def change
    add_column :stocks, :delta, :decimal
  end
end
