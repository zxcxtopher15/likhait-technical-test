require 'rails_helper'

RSpec.describe "Api::Expenses", type: :request do
  let!(:food_category) { Category.create!(name: "Food") }
  let!(:transport_category) { Category.create!(name: "Transport") }

  describe "GET /api/expenses" do
    let!(:older_expense) { Expense.create!(description: "Lunch", amount: 100.00, category: food_category, date: Date.new(2026, 1, 10)) }
    let!(:newer_expense) { Expense.create!(description: "Taxi", amount: 50.00, category: transport_category, date: Date.new(2026, 2, 15)) }

    it "returns all expenses with category information" do
      get "/api/expenses"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end

    it "returns expenses ordered by expense date (most recent first)" do
      get "/api/expenses"

      json = JSON.parse(response.body)
      expect(json.first["id"]).to eq(newer_expense.id)
      expect(json.last["id"]).to eq(older_expense.id)
    end

    it "orders expenses sharing the same date by most recently created first" do
      first_created = Expense.create!(description: "Morning coffee", amount: 5.00, category: food_category, date: Date.new(2026, 3, 1))
      last_created  = Expense.create!(description: "Evening coffee", amount: 6.00, category: food_category, date: Date.new(2026, 3, 1))

      get "/api/expenses"

      json = JSON.parse(response.body)
      same_day_ids = json.map { |e| e["id"] }.select { |id| [ first_created.id, last_created.id ].include?(id) }
      expect(same_day_ids).to eq([ last_created.id, first_created.id ])
    end

    context "when filtering by year and month" do
      it "filters by the expense date, not the creation timestamp" do
        # Incurred in February but recorded (created) in a later month.
        in_month = Expense.create!(
          description: "Backdated February expense",
          amount: 25.00,
          category: food_category,
          date: Date.new(2026, 2, 20),
          created_at: Date.new(2026, 4, 1)
        )
        # Incurred in March but recorded during February.
        out_of_month = Expense.create!(
          description: "March expense logged early",
          amount: 30.00,
          category: food_category,
          date: Date.new(2026, 3, 5),
          created_at: Date.new(2026, 2, 1)
        )

        get "/api/expenses", params: { year: 2026, month: 2 }

        json = JSON.parse(response.body)
        ids = json.map { |e| e["id"] }
        expect(ids).to include(in_month.id)
        expect(ids).not_to include(out_of_month.id)
      end
    end
  end

  describe "POST /api/expenses" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          expense: {
            description: "Team Lunch",
            amount: 150.50,
            category_id: food_category.id,
            date: Date.today
          }
        }
      end

      it "creates a new expense" do
        expect {
          post "/api/expenses", params: valid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["description"]).to eq("Team Lunch")
        expect(json["amount"]).to eq("150.5")
      end
    end

    context "with invalid parameters" do
      it "with negative amounts" do
        invalid_params = {
          expense: {
            description: "Invalid expense",
            amount: -100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it "with empty descriptions" do
        invalid_params = {
          expense: {
            description: "",
            amount: 100.00,
            category_id: food_category.id,
            date: Date.today
          }
        }

        expect {
          post "/api/expenses", params: invalid_params, as: :json
        }.to change(Expense, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end
end
