class Restaurant < ApplicationRecord
  has_many :menu_items, dependent: :destroy

  validates :name, :address, presence: true
end
