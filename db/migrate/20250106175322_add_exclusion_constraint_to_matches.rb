class AddExclusionConstraintToMatches < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'btree_gist'

    add_index :matches, [ :player1_id, :start_time, :end_time ], name: 'index_matches_on_player1_and_time'
    execute <<-SQL
      ALTER TABLE matches
      ADD CONSTRAINT no_overlap_for_player1
      EXCLUDE USING GIST (
        player1_id WITH =,
        tsrange(start_time, end_time) WITH &&
      );
    SQL

    add_index :matches, [ :player2_id, :start_time, :end_time ], name: 'index_matches_on_player2_and_time'
    execute <<-SQL
      ALTER TABLE matches
      ADD CONSTRAINT no_overlap_for_player2
      EXCLUDE USING GIST (
        player2_id WITH =,
        tsrange(start_time, end_time) WITH &&
      );
    SQL
  end
end
