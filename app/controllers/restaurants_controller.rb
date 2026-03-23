class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:show, :update, :destroy]

  # GET /restaurants
  def index
    limit = [params.fetch(:limit, 50).to_i, 100].min
    cursor = params[:cursor] || params[:last_id]

    query = Restaurant.order(id: :desc)
    query = query.where("id < ?", cursor) if cursor.present?
    restaurant_ids = query.limit(limit).pluck(:id)

    json_strings = Restaurant.fetch_cached_entities(restaurant_ids)
    next_cursor = restaurant_ids.last

    render json: %Q({"data":{"items":[#{json_strings.join(',')}],"next_cursor":#{next_cursor || "null"}}})
  end

  # GET /restaurants/:id
  def show
    json_string = Rails.cache.fetch("restaurant_api_show_#{params[:id]}") do
      restaurant = Restaurant.find(params[:id])
      # Include menu_items in the payload and pre-render to JSON string
      restaurant.as_json(include: :menu_items).to_json
    end
    
    render json: json_string
  end

  # POST /restaurants
  def create
    @restaurant = Restaurant.new(restaurant_params)

    if @restaurant.save
      render json: @restaurant, status: :created
    else
      render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /restaurants/:id
  def update
    if @restaurant.update(restaurant_params)
      render json: @restaurant
    else
      render json: { errors: @restaurant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /restaurants/:id
  def destroy
    @restaurant.destroy!
    head :no_content
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params.expect(:id))
  end

  def restaurant_params
    params.expect(restaurant: [:name, :address, :phone, :opening_hours])
  end
end
