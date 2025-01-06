class MatchesController < ApplicationController
  include Overlappable

  before_action :set_match, only: %i[ show update destroy ]

  STATUSES = %w[ upcoming ongoing completed ].freeze

  # GET /matches
  def index
    @matches = Match.all

    @matches = @matches.by_date(matches_search_params[:date]) if matches_search_params[:date].present?
    @matches = @matches.by_status(matches_search_params[:status]) if matches_search_params[:status].present?

    render json: @matches
  end

  # GET /matches/1
  def show
    render json: @match
  end

  # POST /matches
  def create
    rescue_from_overlap_error do
      @match = Match.new(match_params)
      if @match.save
        render json: @match, status: :created, location: @match
      else
        render json: @match.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /matches/1
  def update
    rescue_from_overlap_error do
      if @match.update(match_params)
        render json: @match
      else
        render json: @match.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /matches/1
  def destroy
    @match.destroy!
  end

  private

  def set_match
    @match = Match.find(params.expect(:id))
  end

  def match_params
    params.expect(match: [ :start_time, :end_time, :player1_id, :player2_id, :winner_id, :table_number ])
  end

  def matches_search_params
    params.permit(:date, :status)
  end
end
