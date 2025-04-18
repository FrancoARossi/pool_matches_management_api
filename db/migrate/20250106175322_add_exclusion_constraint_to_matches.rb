class AddExclusionConstraintToMatches < ActiveRecord::Migration[8.0]
  def up
    # only supported in PostgreSQL
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

  def down
    remove_index :matches, name: 'index_matches_on_player1_and_time'
    remove_index :matches, name: 'index_matches_on_player2_and_time'

    execute <<-SQL
      ALTER TABLE matches
      DROP CONSTRAINT no_overlap_for_player1;
    SQL

    execute <<-SQL
      ALTER TABLE matches
      DROP CONSTRAINT no_overlap_for_player2;
    SQL

    disable_extension 'btree_gist'
  end
end
