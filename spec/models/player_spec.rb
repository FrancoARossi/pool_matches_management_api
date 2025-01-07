require 'rails_helper'

RSpec.describe Player, type: :model do
  it "is valid with a name" do
    player = Player.new(name: "John Doe")
    expect(player).to be_valid
  end

  it "is invalid without a name" do
    player = Player.new(name: nil)
    player.valid?
    expect(player.errors[:name]).to include("can't be blank")
  end

  context "with matches" do
    let(:player_1) { Player.create(name: "John Doe") }
    let(:player_2) { Player.create(name: "Jane Doe") }
    let(:player_3) { Player.create(name: "Foo Bar") }
    let(:match_1) { Match.create(player1: player_1, player2: player_2, start_time: Time.current, end_time: Time.current + 1.hour) }
    let(:match_2) { Match.create(player1: player_2, player2: player_1, start_time: Time.current + 1.day, end_time: Time.current + 1.day + 1.hour) }
    let(:match_3) { Match.create(player1: player_1, player2: player_3, start_time: Time.current + 2.days, end_time: Time.current + 2.days + 1.hour) }

    before do
      match_2.update(winner: player_1)
    end

    it "has many won matches" do
      expect(player_1.won_matches).to include(match_2)
    end

    it "has many matches as player1" do
      expect(player_1.matches_as_player1).to include(match_1, match_3)
    end

    it "has many matches as player2" do
      expect(player_1.matches_as_player2).to include(match_2)
    end

    it "has many matches" do
      expect(player_1.matches).to include(match_1, match_2, match_3)
    end

    it "can be found by name" do
      expect(Player.by_name("Doe")).to include(player_1, player_2)
    end
  end
end
