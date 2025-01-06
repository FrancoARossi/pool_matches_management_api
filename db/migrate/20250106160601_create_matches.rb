class CreateMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :matches do |t|
      t.timestamp :start_time, null: false
      t.timestamp :end_time, null: false
      t.references :player1, null: false, foreign_key: { to_table: :players }
      t.references :player2, null: false, foreign_key: { to_table: :players }
      t.references :winner, null: true, foreign_key: { to_table: :players }
      t.integer :table_number, null: true

      t.timestamps
    end
  end
end
