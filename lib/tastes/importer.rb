class Tastes::Importer
  DATA_DIR = Rails.root + 'data/tastes'
  TASTE_FILE = DATA_DIR + 'tastes.csv'
  CATEGORY_FILE = DATA_DIR + 'categories.csv'
  TAG_FILE = DATA_DIR + 'tags.csv'

  attr_accessor :tastes

  def self.process
    new.process
  end

	def self.import_photos
    TasteCategory::LIST.keys.each do |key|
      scope_name = TasteCategory::SCOPE_MAPPER[key]
      tastes = Taste.send scope_name

      tastes.each do |taste|
        # destroying old photos to remove the duplicate conflicts
        taste.photos.delete_all

        path = Rails.root.to_s + "/data/category_images" + "/" + scope_name + "/" + taste.import_string + "/*.png"
        Dir[path].each do |file|
          taste.photos << Photo.stock.create!(file: File.new(file, "r"))
          puts file + " -> done"
        end

        path = Rails.root.to_s + "/data/taste_profile_images" + "/" + scope_name + "/" + taste.import_string + "/*.png"
        files = Dir[path]

        if files.present?
          taste.profile_photo = File.new(files.first, "r")
          taste.save
        end

      end
    end
  end

  def initialize
  end

  def process
    process_tastes
    process_tags
    process_categories
  end

  def taste_names
    tastes.keys
  end

  def process_tastes
    SmarterCSV.process(Tastes::Importer::TASTE_FILE).each do |taste|
      id = taste.delete :id
      taste[:taste_category_id] = TasteCategory::LIST[taste.delete(:category)]

      Taste.where(id: id).first_or_create.update(taste)
    end
    @tastes = {}.tap do |list|
      Taste.all.each do |taste|
        list[taste.import_string.downcase] = taste
      end
    end

    return
  end

  def process_tags
    options = {downcase_header: true, strings_as_keys: true}
    SmarterCSV.process(Tastes::Importer::TAG_FILE, options).each do |data|
      tag = Tag.find_by(name: data['name'])

      if tag.present?
        puts tag.name
        taste_names.each do |name|
          if data[name].present? && data[name] == 1
            taste = tastes[name]
            unless tag.tastes.include?(taste)
              tag.tastes << taste
            end
          end
        end
      end
    end

    return
  end

  def process_categories
    options = {downcase_header: true, strings_as_keys: true}
    SmarterCSV.process(Tastes::Importer::CATEGORY_FILE, options).each do |data|
      category = Category.find_by(name: data['name'])

      if category.present?
        taste_names.each do |name|
          if data[name].present? && data[name] == 1
            taste = tastes[name]
            unless category.tastes.include?(taste)
              category.tastes << taste
            end
          end
        end
      end
    end

    return
  end

end