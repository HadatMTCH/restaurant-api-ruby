class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:show, :update, :destroy]

  # GET /restaurants
  def index
    page = [params.fetch(:page, 1).to_i, 1].max
    per_page = [params.fetch(:per, 10).to_i, 100].min
    
    @restaurants = Restaurant.limit(per_page).offset((page - 1) * per_page)
    render json: @restaurants
  end

  # GET /restaurants/:id
  def show
    # Include menu_items in the response as requested
    render json: @restaurant.as_json(include: :menu_items)
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
