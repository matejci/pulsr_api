class Eventful::Importer::WithdrawEvent < Eventful::Importer::Core
  def object
    "event"
  end

  def period
    "daily"
  end

  def action
    "withdrawn"
  end

  def process
    Eventful::Event.withdraw_xml file_to_process
  end

end