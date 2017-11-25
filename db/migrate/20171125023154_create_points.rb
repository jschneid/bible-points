class CreatePoints < ActiveRecord::Migration[5.1]
  def change
    create_table :points do |t|
      t.references :book, foreign_key: true
      t.integer :chapter
      t.string :text

      t.timestamps
    end
  end
end
