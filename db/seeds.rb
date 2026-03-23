# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Cleaning up database..."
MenuItem.destroy_all
Restaurant.destroy_all

puts "Creating Restaurants..."

r1 = Restaurant.create!(
  name: "Spicy Thai Authentic",
  address: "123 Sukhumvit Road",
  phone: "02-123-4567",
  opening_hours: "10:00 - 22:00"
)

r2 = Restaurant.create!(
  name: "Burger Joint",
  address: "456 Silom Road",
  phone: "02-987-6543",
  opening_hours: "11:00 - 23:00"
)

puts "Creating Menu Items..."

[
  { name: "Pad Thai", description: "Stir-fried rice noodles", price: 120.50, category: "main" },
  { name: "Tom Yum Goong", description: "Spicy sour prawn soup", price: 180.00, category: "main" },
  { name: "Som Tum", description: "Papaya salad", price: 80.00, category: "appetizer" },
  { name: "Mango Sticky Rice", description: "Classic Thai dessert", price: 100.00, category: "dessert" },
  { name: "Thai Iced Tea", description: "Sweet milk tea", price: 60.00, category: "drink" }
].each do |item|
  r1.menu_items.create!(item)
end

[
  { name: "Classic Cheeseburger", description: "Beef patty with cheese", price: 250.00, category: "main" },
  { name: "Bacon Burger", description: "Beef patty with bacon", price: 280.00, category: "main" },
  { name: "French Fries", description: "Crispy potato fries", price: 100.00, category: "appetizer" },
  { name: "Onion Rings", description: "Deep fried onion rings", price: 120.00, category: "appetizer" },
  { name: "Chocolate Milkshake", description: "Rich chocolate flavor", price: 150.00, category: "drink" }
].each do |item|
  r2.menu_items.create!(item)
end

puts "Created #{Restaurant.count} restaurants and #{MenuItem.count} menu items!"
