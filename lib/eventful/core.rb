class Eventful::Core
  class << self
    def extract_performers(data)
      performers = []

      if (data = data['performers'])
        if data.is_a? Array
          data.each do |performer|
            performers += get_performer(performer)
          end
        else
          performers += get_performer(data)
        end
      end

      performers
    end

    def get_performer(data)
      if (performer = data['performer'])
        if performer.is_a? Array
          [].tap do |data|
            performer.each do |perf|
              data << perf['id'] if perf['id']
            end
          end
        else
          [performer['id']] if performer['id']
        end
      end
    end

    def extract_links(data)
      links = []
      if data['links'] && data['links']['link']
        content = data['links']['link']

        if content.is_a? Array
          content.each do |link|
            links << {
              description: link['description'],
              url: link['url'],
              type: link['type']
            }
          end
        else
          links << {
            description: content['description'],
            url: content['url'],
            type: content['type']
          }
        end

      end

      links
    end

    def extract_images(data)
      images = []

      data = data["images"] if data["images"].present?

      if data.present? && data['image'].present?
        if data['image'].is_a? Array
          data['image'].each do |element|
            image = get_url(element)
            images << image if image.present?
          end
        else
          key = data['image'].keys.first

          image_data = data['image'][key]
          images << image_data["url"] if image_data.present? && image_data["url"].present?
        end
      end

      images
    end

    def get_url(data)
      key = data.keys.first

      data[key]['url']
    end
  end
end