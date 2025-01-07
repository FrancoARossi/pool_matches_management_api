class Match < ApplicationRecord
  validates :start_time, presence: true
  validates :end_time, presence: true, comparison: { greater_than: :start_time }
  validates :player1_id, presence: true, comparison: { other_than: :player2_id }
  validates :player2_id, presence: true
  validate :no_overlapping_matches

  belongs_to :player1, class_name: "Player", foreign_key: "player1_id"
  belongs_to :player2, class_name: "Player", foreign_key: "player2_id"
  belongs_to :winner, class_name: "Player", foreign_key: "winner_id", optional: true

  after_commit :update_player_ranking

  scope :by_date, ->(date) {
    where("TO_CHAR(start_time, 'YYYY-MM-DD') = ?", date)
    .or(where("TO_CHAR(end_time, 'YYYY-MM-DD') = ?", date))
  }
  scope :by_status, ->(status) {
    case status
    when "upcoming"
      where("start_time > ?", Time.current)
    when "ongoing"
      where("start_time <= ? AND end_time >= ?", Time.current, Time.current)
    when "completed"
      where("end_time < ?", Time.current)
    end
  }

  private

  def no_overlapping_matches
    throw :abort if player1_id.blank? || player2_id.blank?

    overlapping_match_for_player1 = player1.matches
                                            .where.not(id:)
                                            .where("start_time < ? AND end_time > ?", end_time, start_time)
                                            .exists?

    overlapping_match_for_player2 = player2.matches
                                            .where.not(id:)
                                            .where("start_time < ? AND end_time > ?", end_time, start_time)
                                            .exists?

    errors.add(:player1, "cannot have overlapping matches") if overlapping_match_for_player1
    errors.add(:player2, "cannot have overlapping matches") if overlapping_match_for_player2
  end

  def update_player_ranking
    UpdateRankingsJob.perform_later
  end
end
