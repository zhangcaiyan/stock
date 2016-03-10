class CreateImportAuctions < ActiveRecord::Migration
  def change
    create_table :import_auctions do |t|
      t.string :category
      t.string :children_category
      t.string :name
      t.string :sku
      t.string :img
      t.string :import_id

      t.timestamps null: false
    end

    add_index :import_auctions, :import_id
    add_index :import_auctions, :sku
    add_index :import_auctions, [:category, :children_category]
  end
end
