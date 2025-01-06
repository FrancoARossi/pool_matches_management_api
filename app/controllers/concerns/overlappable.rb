module Overlappable
  extend ActiveSupport::Concern

  included do
    def rescue_from_overlap_error(&block)
      yield
    rescue ActiveRecord::StatementInvalid => e
      errors = []
      errors.push("Player 1 has overlapping matches") if e.message.include?("no_overlap_for_player1")
      errors.push("Player 2 has overlapping matches") if e.message.include?("no_overlap_for_player2")

      if errors.any?
        render json: { errors: }, status: :unprocessable_entity
      else
        raise
      end
    end
  end
end
