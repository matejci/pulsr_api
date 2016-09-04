class Eventful::Importer::UpdateVenue < Eventful::Importer::Core

  def object
    "venue"
  end

  def period
    "daily"
  end

  def action
    "updates"
  end

  def process
    Eventful::Venue.update_xml file_to_process
  end

end