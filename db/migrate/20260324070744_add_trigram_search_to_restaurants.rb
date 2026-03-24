class AddTrigramSearchToRestaurants < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')
    add_index :restaurants, :name, opclass: :gin_trgm_ops, using: :gin
  end
end
