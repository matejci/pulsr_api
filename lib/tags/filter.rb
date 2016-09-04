class Tags::Filter
  FILE = Rails.root + "data/tags_not_to_display.csv"

  def self.process
    filters = SmarterCSV.process(Rails.root + "data/tags_not_to_display.csv")

    filters.each do |filter|
      Tag.by_regex(filter[:tag]).update_all(hidden: true)
    end
  end
end