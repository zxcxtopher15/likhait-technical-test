class Expense < ApplicationRecord
  belongs_to :category

  validate :date_cannot_be_in_the_future

  private

  # You can't spend money on a day that hasn't happened yet
  def date_cannot_be_in_the_future
    return if date.blank?

    errors.add(:date, "can't be in the future") if date > Date.current
  end
end
