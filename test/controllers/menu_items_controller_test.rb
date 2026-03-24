require "test_helper"

class MenuItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restaurant = restaurants(:restaurant_1)
    @menu_item = menu_items(:menu_item_1)
    @user = users(:valid_user)
    @headers = auth_headers_for(@user)
  end

  test "should get index for restaurant" do
    get restaurant_menu_items_url(@restaurant), headers: @headers
    assert_response :success
    data = JSON.parse(response.body)["data"]
    assert_equal 2, data["items"].length
  end

  test "should create menu item" do
    assert_difference("MenuItem.count") do
      post restaurant_menu_items_url(@restaurant), params: { menu_item: { name: "Salad", description: "Fresh", price: 5.99, category: "Appetizer", is_available: true } }, headers: @headers
    end
    assert_response :created
  end

  test "should update menu item using shallow route" do
    patch menu_item_url(@menu_item), params: { menu_item: { price: 10.99 } }, headers: @headers
    assert_response :success
    @menu_item.reload
    assert_equal 10.99, @menu_item.price
  end

  test "should destroy menu item using shallow route" do
    assert_difference("MenuItem.count", -1) do
      delete menu_item_url(@menu_item), headers: @headers
    end
    assert_response :no_content
  end
end
