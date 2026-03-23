module EntityCacheable
  extend ActiveSupport::Concern

  included do
    after_commit :invalidate_entity_cache, on: [:update, :destroy]
  end

  def invalidate_entity_cache
    cache_prefix = "#{self.class.model_name.param_key}_api"
    Rails.cache.delete("#{cache_prefix}_#{self.id}")
    Rails.cache.delete("#{cache_prefix}_show_#{self.id}")
  end

  module ClassMethods
    # Fetches pre-rendered JSON strings for the given array of IDs from Redis.
    # On cache miss, hydrates the entities from the database, caches their JSON,
    # and returns them perfectly in the order of the source array.
    def fetch_cached_entities(ids)
      return [] if ids.blank?

      cache_prefix = "#{model_name.param_key}_api"
      cache_keys = ids.map { |id| "#{cache_prefix}_#{id}" }
      cached_hash = Rails.cache.read_multi(*cache_keys)

      missing_keys = cache_keys - cached_hash.keys
      if missing_keys.any?
        missing_ids = missing_keys.map { |k| k.split('_').last.to_i }
        
        # Hydrate from DB
        missing_records = where(id: missing_ids).index_by(&:id)
        
        missing_records.each do |id, record|
          key = "#{cache_prefix}_#{id}"
          
          json_string = record.to_json
          
          Rails.cache.write(key, json_string)
          cached_hash[key] = json_string
        end
      end

      ids.map { |id| cached_hash["#{cache_prefix}_#{id}"] }.compact
    end
  end
end
