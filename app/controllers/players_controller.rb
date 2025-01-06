class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show update destroy ]

  # GET /players
  def index
    @players = Player.all

    @players = @players.by_name(players_search_params[:name]) if players_search_params[:name].present?

    render json: @players
  end

  # GET /players/1
  def show
    render json: @player
  end

  # POST /players
  def create
    @player = Player.new(player_params)
    if @player.save
      render json: @player, status: :created, location: @player
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /players/1
  def update
    if @player.update(player_params)
      render json: @player
    else
      render json: @player.errors, status: :unprocessable_entity
    end
  end

  # DELETE /players/1
  def destroy
    @player.destroy!
  end

  # GET /players/leaderboard
  def leaderboard
    @players = Player.order(ranking: :desc).limit(10)
    render json: @players
  end

  private

  def set_player
    @player = Player.find(params.expect(:id))
  end

  def player_params
    params.expect(player: [ :name, :ranking, :preferred_cue ])
  end

  def players_search_params
    params.permit(:name)
  end
end
