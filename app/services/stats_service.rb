class StatsService
  include RedisConn

  CAMERA_PREFIX = "camera_model_"
  FORMAT_PREFIX = "image_type_"

  class << self
    def stats_report
      {
        cameras: stat_by_prefix(CAMERA_PREFIX),
        formats: stat_by_prefix(FORMAT_PREFIX),
        days: Image.where('created_at > ?', 30.days.ago)
                    .group_by { |img| img.created_at.to_date }
                    .transform_values(&:count)
        # this shoul also go into redis but wanted to save time
      }
    end

    def save_stats(image, type)
      magic = MiniMagick::Image.open(image)
      model = magic.exif["Model"] || "unknown"
      update_counter("#{CAMERA_PREFIX}#{model}")
      update_counter("#{FORMAT_PREFIX}#{type}")
    end

    def update_counter(counter)
      current = RedisConn.current.get(counter) || 0
      RedisConn.current.set(counter, current.to_i + 1)
    end

    def stat_by_prefix(prefix)
      cameras = {}
      RedisConn.current.keys("#{prefix}*").each do |key|
        cameras[key.delete_prefix(prefix)] = RedisConn.current.get(key).to_i
      end

      cameras
    end
  end
end
