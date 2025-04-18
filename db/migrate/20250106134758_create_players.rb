class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.integer :ranking, default: 0
      t.string :preferred_cue, null: true

      t.timestamps
    end
  end
end
