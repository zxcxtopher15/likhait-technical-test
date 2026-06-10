class Category < ApplicationRecord
  has_many :expenses, dependent: :destroy

  # Name is required and must be unique (matches the unique index on the table)
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { maximum: 100 }
end
