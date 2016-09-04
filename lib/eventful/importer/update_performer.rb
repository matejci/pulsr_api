class Eventful::Importer::UpdatePerformer < Eventful::Importer::Core
  def object
    "performer"
  end

  def period
    "daily"
  end

  def action
    "updates"
  end

  def process
    Eventful::Performer.update_xml file_to_process
  end

end