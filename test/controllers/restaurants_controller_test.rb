require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restaurant = restaurants(:restaurant_1)
    @user = users(:valid_user)
    @headers = auth_headers_for(@user)
  end

  test "should get index with cursor pagination" do
    # Verify unauthorized without headers
    get restaurants_url
    assert_response :unauthorized

    get restaurants_url, params: { limit: 1 }, headers: @headers
    assert_response :success
    data = JSON.parse(response.body)["data"]
    assert_equal 1, data["items"].length

    # Test cursor pagination (it's ordered by id desc)
    restaurant_ids = data["items"].map { |i| i["id"] }
    next_cursor = data["next_cursor"]
    assert_equal restaurant_ids.last, next_cursor

    # Second page
    get restaurants_url, params: { cursor: next_cursor, limit: 1 }, headers: @headers
    assert_response :success
    data2 = JSON.parse(response.body)["data"]
    assert_equal 1, data2["items"].length
  end

  test "should show restaurant" do
    get restaurant_url(@restaurant), headers: @headers
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @restaurant.id, json["id"]
  end

  test "should create restaurant" do
    assert_difference("Restaurant.count") do
      post restaurants_url, params: { restaurant: { name: "New Rest", address: "abc", phone: "123", opening_hours: "9-5" } }, headers: @headers
    end
    assert_response :created
  end

  test "should update restaurant" do
    patch restaurant_url(@restaurant), params: { restaurant: { name: "Updated Rest" } }, headers: @headers
    assert_response :success
    @restaurant.reload
    assert_equal "Updated Rest", @restaurant.name
  end

  test "should destroy restaurant" do
    assert_difference("Restaurant.count", -1) do
      delete restaurant_url(@restaurant), headers: @headers
    end
    assert_response :no_content
  end
end
