class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.string :name
      t.boolean :testament
      t.integer :chapter

      t.timestamps
    end
  end
end
