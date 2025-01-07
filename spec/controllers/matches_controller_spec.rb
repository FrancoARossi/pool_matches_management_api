RSpec.describe MatchesController, type: :controller do
  let!(:player1) { Player.create(name: "John Doe") }
  let!(:player2) { Player.create(name: "Jane Doe") }

  before do
    Timecop.freeze(Time.current)
  end

  after do
    Timecop.return
  end

  let!(:match_1) do
    Match.create!(
      player1: player1,
      player2: player2,
      start_time: Time.current.change(usec: 0) + 1.day + 1.hour,
      end_time: Time.current.change(usec: 0) + 1.day + 2.hours
    )
  end
  let!(:match_2) do
    Match.create!(
      player1: player2,
      player2: player1,
      start_time: Time.current.change(usec: 0) - 1.hour,
      end_time: Time.current.change(usec: 0) + 1.hour
    )
  end
  let!(:match_3) do
    Match.create!(
      player1: player1,
      player2: player2,
      start_time: Time.current.change(usec: 0) - 2.hours,
      end_time: Time.current.change(usec: 0) - 1.hour
    )
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
      expect(JSON.parse(response.body).size).to eq(3)
    end

    context "with date filter param" do
      it "returns a success response" do
        get :index, params: { date: Time.current.strftime("%Y-%m-%d") }
        expect(response).to be_successful
        expect(JSON.parse(response.body).size).to eq(2)
      end
    end

    context "with status filter param" do
      it "returns a success response" do
        get :index, params: { status: "upcoming" }
        expect(response).to be_successful
        expect(JSON.parse(response.body).size).to eq(1)
        expect(JSON.parse(response.body).first["id"]).to eq(match_1.id)
      end

      it "returns a success response" do
        get :index, params: { status: "ongoing" }
        expect(response).to be_successful
        expect(JSON.parse(response.body).size).to eq(1)
        expect(JSON.parse(response.body).first["id"]).to eq(match_2.id)
      end

      it "returns a success response" do
        get :index, params: { status: "completed" }
        expect(response).to be_successful
        expect(JSON.parse(response.body).size).to eq(1)
        expect(JSON.parse(response.body).first["id"]).to eq(match_3.id)
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: match_1.id }
      expect(response).to be_successful
      expect(JSON.parse(response.body)["id"]).to eq(match_1.id)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:valid_params) do
        {
          start_time: Time.current + 2.days,
          end_time: Time.current + 2.days + 1.hour,
          player1_id: player1.id,
          player2_id: player2.id,
          winner_id: player1.id,
          table_number: 1
        }
      end

      it "creates a new Match" do
        expect {
          post :create, params: { match: valid_params }
        }.to change(Match, :count).by(1)
      end

      it "renders a JSON response with the new match" do
        post :create, params: { match: valid_params }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response.location).to eq(match_url(Match.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new match" do
        post :create, params: { match: { start_time: nil, end_time: nil, player1_id: nil, player2_id: nil, winner_id: nil, table_number: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates the requested match" do
        new_start_time = match_1.start_time + 3.days
        new_end_time = match_1.end_time + 3.days
        patch :update, params: { id: match_1.id, match: { start_time: new_start_time, end_time: new_end_time, player1_id: player1.id, player2_id: player2.id, winner_id: player1.id, table_number: 1 } }
        match_1.reload
        expect(match_1.start_time).to eq(new_start_time)
        expect(match_1.end_time).to eq(new_end_time)
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the match" do
        patch :update, params: { id: match_1.id, match: { start_time: nil, end_time: nil, player1_id: nil, player2_id: nil, winner_id: nil, table_number: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested match" do
      expect {
        delete :destroy, params: { id: match_1.id }
      }.to change(Match, :count).by(-1)
    end
  end
end
