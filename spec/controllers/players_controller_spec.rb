RSpec.describe PlayersController, type: :controller do
  let!(:player1) { Player.create(name: "John Doe") }
  let!(:player2) { Player.create(name: "Jane Doe") }

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
      expect(JSON.parse(response.body).size).to eq(2)
    end

    context "with search params" do
      it "returns a success response" do
        get :index, params: { name: "John" }
        expect(response).to be_successful
        expect(JSON.parse(response.body).size).to eq(1)
        expect(JSON.parse(response.body).first["id"]).to eq(player1.id)
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: player1.id }
      expect(response).to be_successful
      expect(JSON.parse(response.body)["id"]).to eq(player1.id)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Player" do
        expect {
          post :create, params: { player: { name: "Foo Bar" } }
        }.to change(Player, :count).by(1)
      end

      it "renders a JSON response with the new player" do
        post :create, params: { player: { name: "John Doe" } }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response.location).to eq(player_url(Player.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new player" do
        post :create, params: { player: { name: nil } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates the requested player" do
        new_name = "Foo Bar"
        patch :update, params: { id: player1.id, player: { name: new_name } }
        player1.reload
        expect(player1.name).to eq(new_name)
      end

      it "renders a JSON response with the player" do
        patch :update, params: { id: player1.id, player: { name: "Foo Bar" } }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested player" do
      expect {
        delete :destroy, params: { id: player1.id }
      }.to change(Player, :count).by(-1)
    end
  end

  describe "GET #leaderboard" do
    before do
      player1.update!(ranking: 2)
      player2.update!(ranking: 1)
    end

    it "returns a success response" do
      get :leaderboard
      expect(response).to be_successful
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end
end
