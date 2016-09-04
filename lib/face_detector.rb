require 'opencv'
require 'net/http'

class FaceDetector
  HAARCASCADE_DATA = Rails.root + "data/haarcascade_frontalface_alt.xml"
  PHOTO_DIR = Rails.root + 'data/images'
  SELFIE_THRESHOLD = 0.20
  ASPECT_WIDTH = 187.0
  ASPECT_HEIGHT = 59.0
  ASPECT = ASPECT_HEIGHT / ASPECT_WIDTH

  class << self
    def detector
      @detector ||= OpenCV::CvHaarClassifierCascade::load(HAARCASCADE_DATA.to_path)
    end

    def get_photo(name)
      path = PHOTO_DIR + name
    end

    def analyze_photo_from_file(file_path)
      path = FaceDetector.get_photo(file_path).to_path
      image_file = IO.binread(path)

      analyze_photo(image_file)
    end

    def analyze_photo_from_memory(image)
      analyze_photo(image)
    end

    def analyze_photo_from_url(url)
      image_file = FileDownloader.photo_from_url(url)

      result = image_file.present? ? analyze_photo(image_file.read) : {}
    ensure
      image_file.close

      result
    end

    # x - number of faces
    # x - list of boundaries for each face
    # x - photo type: portrait|landscape|selfie
    # x - close_shot: bool if the are of faces is taking more than a half of the area on the photo
    # x - total boundary enclosing all the faces on the photo, this is useful if you will want to crop around the faces
    # - aspect_crop, boolean if you can crop the photo to fit the aspect ratio you’ve provided to me
    # x - center_crop, possible to crop the center
    def analyze_photo(image_file)
      image = OpenCV::IplImage.decode_image(image_file)
      regions = detect_faces(image)

      metadata = {
        number_faces: regions.count,
        faces: [],
        width: image.width,
        height: image.height
      }

      if metadata[:number_faces] > 0
        boundaries = {
          top_right: [],
          bottom_left: []
        }

        regions.each do |region|
          face = {
            bottom_left: region.bottom_left.to_a,
            top_right: region.top_right.to_a,
            center: region.center.to_a
          }
          boundaries = detect_edge_boundaries(boundaries, face)
          metadata[:faces] << face
        end

        boundaries[:center] = [
          (boundaries[:bottom_left][0] + boundaries[:top_right][0]) / 2.0,
          (boundaries[:bottom_left][1] + boundaries[:top_right][1]) / 2.0
        ]
        boundaries[:width] = boundaries[:top_right][0] - boundaries[:bottom_left][0]
        boundaries[:height] = boundaries[:bottom_left][1] - boundaries[:top_right][1]
        boundaries[:x] = boundaries[:bottom_left][0]
        boundaries[:y] = boundaries[:top_right][1]
        metadata[:boundaries] = boundaries
        metadata[:close_shot] = is_close_shot(image, boundaries)

        # metadata[:aspect_crop] = can_aspect_crop? image, boundaries
        # metadata[:center_crop] = metadata[:aspect_crop] ? can_center_crop?(image, boundaries) : false
        metadata[:center_crop] = can_center_crop?(image, boundaries)
        metadata[:photo_type] = metadata[:close_shot] ? 'selfie' : 'portrait'
      else
        metadata[:close_shot] = false
        metadata[:center_crop] = true
        metadata[:aspect_crop] = true
        metadata[:photo_type] = 'landscape'
      end

      metadata
    end

    def can_center_crop? image, boundaries
      half_width = image.width / 2.0
      half_height = image.height / 2.0

      if boundaries[:x] < half_width
        # left half
        x = boundaries[:x]
        width = (half_width - x) * 2.0

        # process longer than width
        width_diff = width - boundaries[:width]
        if width_diff > 0
          x = x - width_diff
          width += width_diff * 2
          return false if x < 0
        end

        if boundaries[:y] < half_height
          y = boundaries[:y]
          height = (half_height - y) * 2.0

          # process longer than height
          height_diff = height - boundaries[:height]
          if height_diff > 0
            y = y - height_diff
            height += height_diff * 2
            return false if y < 0
          end
        else
          height = (boundaries[:y] - half_height) * 2.0
          y = half_height - height / 2.0
        end
      else
        # right half
        width = (boundaries[:x] - half_width) * 2.0
        x = half_width - width / 2.0

        if boundaries[:y] < half_height
          y = boundaries[:y]
          height = (half_height - y) * 2.0

          # process longer than height
          height_diff = height - boundaries[:height]
          if height_diff > 0
            y = y - height_diff
            height += height_diff * 2
            return false if y < 0
          end
        else
          height = (boundaries[:y] - half_height) * 2.0
          y = half_height - height / 2.0
        end
      end

      image.width * ASPECT >= height
    end

    def can_aspect_crop? image, boundaries
      true
    end

    def is_close_shot image, boundaries
      area = boundaries[:width] * boundaries[:height]
      image_area = image.height * image.width

      area/image_area.to_f >= SELFIE_THRESHOLD
    end

    def detect_edge_boundaries boundaries, face
      boundaries[:bottom_left][0] = face[:bottom_left][0] unless boundaries[:bottom_left][0].present?
      boundaries[:bottom_left][1] = face[:bottom_left][1] unless boundaries[:bottom_left][1].present?
      boundaries[:top_right][0] = face[:top_right][0] unless boundaries[:top_right][0].present?
      boundaries[:top_right][1] = face[:top_right][1] unless boundaries[:top_right][1].present?

      if face[:bottom_left][0] < boundaries[:bottom_left][0]
        boundaries[:bottom_left][0] = face[:bottom_left][0]
      end
      if face[:bottom_left][1] > boundaries[:bottom_left][1]
        boundaries[:bottom_left][1] = face[:bottom_left][1]
      end
      if face[:top_right][0] > boundaries[:top_right][0]
        boundaries[:top_right][0] = face[:top_right][0]
      end
      if face[:top_right][1] < boundaries[:top_right][1]
        boundaries[:top_right][1] = face[:top_right][1]
      end

      boundaries
    end

    def detect_faces(image)
      detector.detect_objects(image)
    end

    def test_faces(image_name)
      path = FaceDetector.get_photo(image_name).to_path
      save_path = FaceDetector.get_photo('x' + image_name).to_path

      image_file = IO.binread(path)

      image = OpenCV::IplImage.decode_image(image_file)
      detector.detect_objects(image).each do |region|
        color = OpenCV::CvColor::Blue
        image.rectangle! region.top_left, region.bottom_right, :color => color
      end
      image.save_image(save_path)

    end
  end
end