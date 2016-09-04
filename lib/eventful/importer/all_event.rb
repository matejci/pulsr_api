class Eventful::Importer::AllEvent < Eventful::Importer::Core
  def object
    "event"
  end

  def period
    "weekly"
  end

  def action
    "full"
  end

  def process
    Eventful::Event.import_xml file_to_process
  end

end