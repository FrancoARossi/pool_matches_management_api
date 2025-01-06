class Player < ApplicationRecord
  validates :name, presence: true

  has_many :won_matches, class_name: "Match", foreign_key: "winner_id"
  has_many :matches_as_player1, class_name: "Match", foreign_key: "player1_id"
  has_many :matches_as_player2, class_name: "Match", foreign_key: "player2_id"
  has_many :matches, through: :all_matches

  private

  def all_matches
    Match.where({ player1_id: id }).or(Match.where({ player2_id: id }))
  end
end
