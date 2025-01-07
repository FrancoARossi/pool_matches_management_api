RSpec.describe Match, type: :model do
  let!(:player1) { Player.create(name: "John Doe") }
  let!(:player2) { Player.create(name: "Jane Doe") }

  before do
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  context "validations" do
    it "is valid with a start time, end time, player1_id, and player2_id" do
      match = Match.new(
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        player1_id: player1.id,
        player2_id: player2.id
      )
      expect(match).to be_valid
    end

    it "is invalid without a start time" do
      match = Match.new(start_time: nil)
      match.valid?
      expect(match.errors[:start_time]).to include("can't be blank")
    end

    it "is invalid without an end time" do
      match = Match.new(end_time: nil)
      match.valid?
      expect(match.errors[:end_time]).to include("can't be blank")
    end

    it "is invalid without a player1_id" do
      match = Match.new(player1_id: nil)
      match.valid?
      expect(match.errors[:player1_id]).to include("can't be blank")
    end

    it "is invalid without a player2_id" do
      match = Match.new(player2_id: nil)
      match.valid?
      expect(match.errors[:player2_id]).to include("can't be blank")
    end

    it "is invalid if end time is before start time" do
      match = Match.new(start_time: Time.current, end_time: Time.current - 1.hour)
      match.valid?
      expect(match.errors[:end_time]).to include("must be greater than #{match.start_time}")
    end

    it "is invalid if player1_id is the same as player2_id" do
      match = Match.new(player1_id: player1.id, player2_id: player1.id)
      match.valid?
      expect(match.errors[:player1_id]).to include("must be other than #{player1.id}")
    end

    it "is invalid if player1 has an overlapping match" do
      Match.create!(
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        player1_id: player1.id,
        player2_id: player2.id
      )
      match = Match.new(
        start_time: Time.current + 30.minutes,
        end_time: Time.current + 1.hour + 30.minutes,
        player1_id: player1.id,
        player2_id: player2.id
      )
      match.valid?
      expect(match.errors[:player1]).to include("cannot have overlapping matches")
    end

    it "is invalid if player2 has an overlapping match" do
      Match.create!(
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        player1_id: player1.id,
        player2_id: player2.id
      )
      match = Match.new(
        start_time: Time.current + 30.minutes,
        end_time: Time.current + 1.hour + 30.minutes,
        player1_id: player2.id,
        player2_id: player1.id
      )
      match.valid?
      expect(match.errors[:player2]).to include("cannot have overlapping matches")
    end
  end

  context "associations" do
    let!(:match_1) do
      Match.create(
        player1: player1,
        player2: player2,
        start_time: Time.current,
        end_time: Time.current + 1.hour
      )
    end
    let!(:match_2) do
      Match.create(
        player1: player2,
        player2: player1,
        start_time: Time.current + 1.day,
        end_time: Time.current + 1.day + 1.hour
      )
    end
    let!(:match_3) do
      Match.create(
        player1: player1,
        player2: player2,
        start_time: Time.current + 2.days,
        end_time: Time.current + 2.days + 1.hour
      )
    end

    it "belongs to player1" do
      expect(match_1.player1).to eq(player1)
    end

    it "belongs to player2" do
      expect(match_1.player2).to eq(player2)
    end

    it "belongs to winner" do
      match_1.update(winner: player1)
      expect(match_1.winner).to eq(player1)
    end
  end

  context "scopes" do
    let!(:match_1) do
      Match.create!(
        player1: player1,
        player2: player2,
        start_time: Time.current + 1.day + 1.hour,
        end_time: Time.current + 1.day + 2.hours
      )
    end
    let!(:match_2) do
      Match.create!(
        player1: player2,
        player2: player1,
        start_time: Time.current - 1.hour,
        end_time: Time.current + 1.hour
      )
    end
    let!(:match_3) do
      Match.create!(
        player1: player1,
        player2: player2,
        start_time: Time.current - 2.hours,
        end_time: Time.current - 1.hour
      )
    end

    it "can be found by date" do
      expect(Match.by_date(Time.current.strftime("%Y-%m-%d"))).to include(match_2, match_3)
    end

    it "can be found by status" do
      expect(Match.by_status("upcoming")).to include(match_1)
      expect(Match.by_status("ongoing")).to include(match_2)
      expect(Match.by_status("completed")).to include(match_3)
    end
  end
end
