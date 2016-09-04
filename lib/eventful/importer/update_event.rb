class Eventful::Importer::UpdateEvent < Eventful::Importer::Core

  def object
    "event"
  end

  def period
    "daily"
  end

  def action
    "updates"
  end

  def process
    Eventful::Event.update_xml file_to_process
  end

end