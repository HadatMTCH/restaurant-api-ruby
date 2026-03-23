class MenuItemsController < ApplicationController
  before_action :set_restaurant, only: [:index, :create]
  before_action :set_menu_item, only: [:update, :destroy]

  # GET /restaurants/:restaurant_id/menu_items
  def index
    limit = [params.fetch(:limit, 50).to_i, 100].min
    cursor = params[:cursor] || params[:last_id]
    category = params[:category]
    name = params[:name]

    query = @restaurant.menu_items.order(id: :desc)
    query = query.where(category: category) if category.present?
    query = query.where("name ILIKE ?", "%#{name}%") if name.present?
    query = query.where("id < ?", cursor) if cursor.present?
    
    menu_item_ids = query.limit(limit).pluck(:id)

    json_strings = MenuItem.fetch_cached_entities(menu_item_ids)

    next_cursor = menu_item_ids.last

    render json: %Q({"data":{"items":[#{json_strings.join(',')}],"next_cursor":#{next_cursor || "null"}}})
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
