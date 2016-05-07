class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.string :item
      t.integer :quantity
      t.boolean :bought

      t.timestamps null: false
    end
  end
end
