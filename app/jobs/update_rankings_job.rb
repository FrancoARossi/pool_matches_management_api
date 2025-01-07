class UpdateRankingsJob < ApplicationJob
  queue_as :default

  def perform
    ActiveRecord::Base.transaction do
      Player.joins("LEFT JOIN matches ON players.id = matches.winner_id")
            .group("players.id")
            .select("players.id, COUNT(matches.id) AS win_count")
            .order("win_count DESC")
            .each_with_index do |player, index|
              player.update_columns(ranking: index + 1)
            end
    end
  end
end
