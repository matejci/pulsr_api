class Eventful::Importer::AllPerformer < Eventful::Importer::Core
  def object
    "performer"
  end

  def period
    "weekly"
  end

  def action
    "full"
  end

  def process
    Eventful::Performer.import_xml file_to_process
  end

end