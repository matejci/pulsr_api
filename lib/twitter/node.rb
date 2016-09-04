# All coordinates here use (latitude, longitude) format

module Twitter
  class Node

    attr_accessor :parent, :children, :counter, :center, :boundaries,
                  :level, :max_level, :farthest_item, :tweet_center,
                  :left, # left longitude (top left longitude)
                  :right, # right longitude (bottom right longitude)
                  :top, # top latitude (top left latitude)
                  :bottom # top latitude (bottom right latitude)


     def initialize options
      @level = options[:level] || 0
      @max_level = options[:max_level] || 7
      @parent = options[:parent]
      @counter = options[:counter] || 0
      @boundaries = options[:boundaries] || {}
      @left = options[:left]
      @right = options[:right]
      @top = options[:top]
      @bottom = options[:bottom]

      $counter = 0 if @level == 0
      $counter += 1 unless is_parent?
      build
    end

    def build
      prepare_geolocation_data
      build_children if has_children?
    end

    # preprocess for all bounding box corner before calculating center point
    def prepare_geolocation_data
      prepare_boundaries

      if boundaries_present?
        calculate_edges
      else
        calculate_boundaries
      end
    end

    def boundaries_present?
      boundaries.size >= 2
    end

    # add missing corners if only two points provided
    def prepare_boundaries
      prepare_top_left unless boundaries[:top_left]
      prepare_top_right unless boundaries[:top_right]
      prepare_bottom_left unless boundaries[:bottom_left]
      prepare_bottom_right unless boundaries[:bottom_right]
    end

    def prepare_top_left
      if boundaries[:top_right] && boundaries[:bottom_left]
        @boundaries[:top_left] = [boundaries[:top_right][0],
                                 boundaries[:bottom_left][1]]
      end
    end

    def prepare_top_right
      if boundaries[:top_left] && boundaries[:bottom_right]
        @boundaries[:top_right] = [boundaries[:top_left][0],
                                 boundaries[:bottom_right][1]]
      end
    end

    def prepare_bottom_left
      if boundaries[:top_left] && boundaries[:bottom_right]
        @boundaries[:bottom_left] = [boundaries[:bottom_right][0],
                                 boundaries[:top_left][1]]
      end
    end

    def prepare_bottom_right
      if boundaries[:bottom_left] && boundaries[:top_right]
        @boundaries[:bottom_left] = [boundaries[:bottom_left][0],
                                 boundaries[:top_right][1]]
      end
    end


    def calculate_edges
      @left = boundaries[:bottom_left][1]
      @right = boundaries[:top_right][1]
      @top = boundaries[:bottom_left][0]
      @bottom = boundaries[:top_right][0]

      calculate_center
    end

    def calculate_boundaries
      @boundaries[:top_left] = [top, left]
      @boundaries[:top_right] = [top, right]
      @boundaries[:bottom_left] = [bottom, left]
      @boundaries[:bottom_right] = [bottom, right]

      calculate_center
    end

    def calculate_center
      x = bottom + (top - bottom)/2.0
      y = left + (right - left)/2.0

      @center = [x, y]
    end

    def build_children
      @children = Array.new(4)

      # top left child
      self.top_left = Twitter::Node.new(child_options.merge({
        top: boundaries[:top_left][0],
        left: boundaries[:top_left][1],
        bottom: center[0],
        right: center[1]
      }))

      # top right child
      self.top_right = Twitter::Node.new(child_options.merge({
        top: boundaries[:top_right][0],
        left: center[1],
        bottom: center[0],
        right: boundaries[:top_right][1]
      }))

      # bottom left child
      self.bottom_left = Twitter::Node.new(child_options.merge({
        top: center[0],
        left: boundaries[:bottom_left][1],
        bottom: boundaries[:bottom_left][0],
        right: center[1]
      }))

      # bottom right child
      self.bottom_right = Twitter::Node.new(child_options.merge({
        top: center[0],
        left: center[1],
        bottom: boundaries[:bottom_right][0],
        right: boundaries[:bottom_right][1]
      }))
    end

    def child_options
      options = {
        level: level + 1,
        max_level: max_level,
        parent: self
      }
    end

    def has_children?
      level < max_level
    end
    alias_method :is_parent?, :has_children?

    def top_left=(node)
      children[0] = node
    end

    def top_right=(node)
      children[1] = node
    end

    def bottom_right=(node)
      children[2] = node
    end

    def bottom_left=(node)
      children[3] = node
    end

    def top_left
      children[0]
    end

    def top_right
      children[1]
    end

    def bottom_right
      children[2]
    end

    def bottom_left
      children[3]
    end

    def to_s
      if is_parent?
        puts level + '\n'

      end
    end

    def add_tweet tweet, options = {}
      params = if tweet.is_a?(Hash)
        [tweet[:latitude], tweet[:longitude]]
      else
        [tweet.latitude, tweet.longitude]
      end
      params << options

      add_item *params
    end

    def add_item latitude, longitude, options = {}
      if is_parent?
        child = if latitude > center[0]
          longitude < center[1] ? top_left : top_right
        else
          longitude < center[1] ? bottom_left : bottom_right
        end

        child.add_item(latitude, longitude, options)
      else
        process_farthest_item(latitude, longitude, options)
        @counter += 1
        self
      end
    end

    def process_farthest_item latitude, longitude, options = {}
      distance = calculate_tweet_center(latitude, longitude, options)

      if @farthest_item.present?
        if distance > @farthest_item[:distance]
          @farthest_item = {
            latitude: latitude.round(5),
            longitude: longitude.round(5),
            distance: distance.round(5)
          }
        end
      else
        @farthest_item = {
          latitude: latitude.round(5),
          longitude: longitude.round(5),
          distance: distance.round(5)
        }
      end
    end

    def calculate_tweet_center latitude, longitude, options = {}
      if @tweet_center.present?
        new_latitude = (@tweet_center[0] * @counter + latitude)/(@counter + 1)
        new_longitude = (@tweet_center[1] * @counter + longitude)/(@counter + 1)

        @tweet_center = [new_latitude, new_longitude]

        GeoDistance::Flat.geo_distance(latitude, longitude, new_latitude, new_longitude).to_meters
      else
        @tweet_center = [latitude, longitude]
        0
      end
    end

    def reset_counting!
      if level == 0
        @counter = 0
        @tweet_center = nil

        children.each &:reset_counting! if is_parent?
      end
    end

    def clear_counter!
      @counter = 0
      @tweet_center = nil
    end

    def get_leaves
      leaves = []

      if is_parent?
        children.each do |child|
          leaves += child.get_leaves
        end
      else
        leaves << self
      end

      leaves
    end

    def non_empty_leaves
      get_leaves.select {|node| node.counter > 0 }
    end

    def to_tweet_activity
      {
        counter: counter,
        latitude: tweet_center[0].round(5),
        longitude: tweet_center[1].round(5),
        farthest_item: farthest_item,
        level: level,
        boundaries: boundaries
      }
    end

    def to_tweet_activity!
      response = to_tweet_activity
      clear_counter!

      response
    end


    def to_json_file
      {
        counter: counter,
        lat: tweet_center[0].round(5),
        lng: tweet_center[1].round(5),
        r_lat: farthest_item[:latitude].round(5),
        r_lng: farthest_item[:longitude].round(5),
        r_dist: farthest_item[:distance].round(5),
        level: level
      }

    end
  end
end

class BigDecimal
  def to_lat
    to_f
  end

  def to_lng
    to_f
  end
end