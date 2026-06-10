require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:category) { Category.create!(name: "Food") }

  def build_expense(date)
    Expense.new(description: "Lunch", amount: 10.00, category: category, date: date)
  end

  it "is valid with today's date" do
    expect(build_expense(Date.current)).to be_valid
  end

  it "is valid with a past date" do
    expect(build_expense(Date.current - 1)).to be_valid
  end

  it "is invalid with a future date" do
    expense = build_expense(Date.current + 1)
    expect(expense).not_to be_valid
    expect(expense.errors[:date]).to include("can't be in the future")
  end
end
