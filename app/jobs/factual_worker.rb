class FactualWorker < ActiveJob::Base
  queue_as :high_priority

  def perform(url, type)
    case type
    when "full_import"
      Factual::Importer.import_from_file(url)
    when "diff_import"
      Factual::DiffImporter.import_from_file(url)
    when "instagram"
      Instagram::Importer.import_from_url(url)
    end
  rescue Exception => e
    data = {
      name: 'FactualWorker',
      data: {
        type: type,
        url: url
      },
      error: e.message
    }
    Failure.create data

    raise e

  end
end