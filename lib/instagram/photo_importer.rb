class Instagram::PhotoImporter
  @client = Instagram.client

  BATCH_SIZE = 4000
  DEFAULT_RADIUS = 500 # meters

  class << self
    attr_accessor :client

    def importer
      importer = new
    end

    def import_for_venue venue, return_photo_objects = false
      ratelimit = {}
      photo_ids = []

      unless venue.instagram_places.present?
        InstagramPlace.get_for_venue(venue)
      end

      venue.instagram_places.each do |place|
        ratelimit = importer.import_photos_for_place(place)
        photo_ids += ratelimit[:photo_ids]
      end

      venue.update_attribute :instagram_at, Time.current

      ratelimit[:photo_ids] = photo_ids
      ratelimit[:photo_count] = photo_ids.count
      return_photo_objects ? Photo.where(id: photo_ids) : ratelimit
    end

    def import_for_performer performer, return_photo_objects = false
      results = {}
      photo_ids = []

      unless performer.instagram.present?
        performer.get_instagram_user_id!
      end

      if performer.instagram.present?
        results = importer.import_photos_for_user(performer.instagram)
        photo_ids += results[:photo_ids]
      end

      photo_ids.each do |photo_id|
        performer.add_photo(photo_id)
      end

      results[:photo_ids] = photo_ids
      results[:photo_count] = photo_ids.count
      return_photo_objects ? Photo.where(id: photo_ids) : results
    end

    def import_for_event event
      photos = []

      unless event.instagram_places.present?
        InstagramPlace.get_for_venue event.venue if event.venue.present?
      end

      if event.instagram_places.present?
        photos += import_for_venue event.venue, true
      end

      event.performers.each do |performer|
        photos += import_for_performer performer, true
      end

      unless photos.present?
        photos += import_for(event.latitude, event.longitude, true)
      end

      photos.each do |photo|
        event.add_photo(photo)
      end

      event.update_attribute(:photo_processed_at, DateTime.now)

      photos
    end

    def import_for latitude, longitude, return_photo_objects = false
      RateLimiter.add_instagram_limit

      options = {
        distance: Instagram::PhotoImporter::DEFAULT_RADIUS
      }
      results = client.media_search(latitude, longitude, options)
      default_options = {
        meta_content: {
          import_type: Photo::IMPORT_TYPE[:geolocation]
        }
      }

      photo_ids = []
      results.first(10).each do |data|
        photo = Photo.create_instagram(data)
        photo_ids << photo.id
      end

      response = results.ratelimit.to_hash
      response[:photo_count] = results.count
      response[:photo_ids] = photo_ids
      return_photo_objects ? Photo.where(id: photo_ids) : response
    end

    def find_places_for_venue venue
      find_places(venue.latitude, venue.longitude)
    end

    def find_places latitude, longitude
      RateLimiter.add_instagram_limit
      client.location_search(latitude, longitude)
    end

    def find_user_for_performer performer
      instagram_id = nil
      regex = /#{performer.name}/i

      RateLimiter.add_instagram_limit
      client.user_search(performer.name).each do |user|
        if regex =~ user.full_name
          instagram_id = user.id
          break
        end
      end

      instagram_id
    end

    def media_for_tag(tag)
      RateLimiter.add_instagram_limit
      client.tag_recent_media(tag)
    end
  end

  def import_photos_for_place place
    RateLimiter.add_instagram_limit
    results = Instagram::PhotoImporter.client.location_recent_media(place.place_id)

    ids = []
    results.each do |photo|
      ids << Photo.create_instagram_for_place(photo, place).id
    end

    response = results.ratelimit
    response[:photo_count] = results.count
    response[:photo_ids] = ids
    response
  end

  def import_photos_for_user username
    RateLimiter.add_instagram_limit
    results = Instagram::PhotoImporter.client.user_recent_media(username)
    default_options = {
      meta_content: {
        import_type: Photo::IMPORT_TYPE[:instagram_user]
      }
    }

    ids = []
    results.each do |data|
      photo = Photo.create_instagram_for_user(data, username, default_options)
      ids << photo.id
    end

    response = results.ratelimit
    response[:photo_count] = results.count
    response[:photo_ids] = ids
    response
  end
end
