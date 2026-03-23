class MenuItem < ApplicationRecord
  belongs_to :restaurant

  validates :name, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
