# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require 'faker'

# Allow the user to specify custom counts via environment variables, or default to 50/10
restaurants_count = ENV.fetch("RESTAURANTS_COUNT", 50).to_i
menu_items_per_restaurant = ENV.fetch("MENU_ITEMS_PER_RESTAURANT", 10).to_i

puts "Clearing existing data (this might take a moment if you have thousands of records)..."
# Using delete_all instead of destroy_all for much faster clearing (skips callbacks)
MenuItem.delete_all
Restaurant.delete_all

puts "Seeding #{restaurants_count} restaurants, each with #{menu_items_per_restaurant} menu items..."

restaurants_count.times do |i|
  restaurant = Restaurant.create!(
    name: Faker::Restaurant.name,
    address: Faker::Address.full_address,
    phone: Faker::PhoneNumber.phone_number,
    opening_hours: "08:00 - 22:00"
  )

  # Create an array of menu item Hashes to insert them in bulk
  items_data = menu_items_per_restaurant.times.map do
    {
      restaurant_id: restaurant.id,
      name: Faker::Food.dish,
      description: Faker::Food.description,
      price: Faker::Commerce.price(range: 5.0..100.0),
      category: ["Appetizer", "Main Course", "Dessert", "Beverage", "Breakfast"].sample,
      is_available: [true, true, true, false].sample, # 75% availability chance
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  # Insert securely and fast using insert_all
  MenuItem.insert_all!(items_data) if items_data.any?
  
  # Print progress every 10 restaurants
  puts "Created #{i + 1} / #{restaurants_count} restaurants..." if (i + 1) % 10 == 0
end

puts "\n✅ Done! Seeded #{Restaurant.count} restaurants and #{MenuItem.count} menu items."
