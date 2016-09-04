class Eventful::Importer::AllVenue < Eventful::Importer::Core
  def object
    "venue"
  end

  def period
    "weekly"
  end

  def action
    "full"
  end

  def process
    Eventful::Venue.import_xml file_to_process
  end

end