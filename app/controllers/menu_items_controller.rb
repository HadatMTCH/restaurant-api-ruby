class MenuItemsController < ApplicationController
  before_action :set_restaurant, only: [:index, :create]
  before_action :set_menu_item, only: [:update, :destroy]

  # GET /restaurants/:restaurant_id/menu_items
  def index
    page = [params.fetch(:page, 1).to_i, 1].max
    per_page = [params.fetch(:per, 10).to_i, 100].min

    @menu_items = @restaurant.menu_items
    
    # Filter by category if provided query parameter
    @menu_items = @menu_items.where(category: params[:category]) if params[:category].present?
    
    # Filter by name matching if provided
    @menu_items = @menu_items.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?

    @menu_items = @menu_items.limit(per_page).offset((page - 1) * per_page)
    
    render json: @menu_items
  end

  # POST /restaurants/:restaurant_id/menu_items
  def create
    @menu_item = @restaurant.menu_items.build(menu_item_params)

    if @menu_item.save
      render json: @menu_item, status: :created
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /menu_items/:id
  def update
    if @menu_item.update(menu_item_params)
      render json: @menu_item
    else
      render json: { errors: @menu_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /menu_items/:id
  def destroy
    @menu_item.destroy!
    head :no_content
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params.expect(:restaurant_id))
  end

  def set_menu_item
    @menu_item = MenuItem.find(params.expect(:id))
  end

  def menu_item_params
    params.expect(menu_item: [:name, :description, :price, :category, :is_available])
  end
end
