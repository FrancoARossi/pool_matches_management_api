class Match < ApplicationRecord
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :end_time, comparison: { greater_than: :start_time }
  validates :player1_id, presence: true, comparison: { other_than: :player2_id }
  validates :player2_id, presence: true

  belongs_to :player1, class_name: "Player", foreign_key: "player1_id"
  belongs_to :player2, class_name: "Player", foreign_key: "player2_id"
  belongs_to :winner, class_name: "Player", foreign_key: "winner_id", optional: true
end
