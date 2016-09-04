class Eventful::Performer
  attr_accessor :event, :performer_id, :object, :data

  class << self
    def process! performer, event = nil
      new(performer, event).create
    end

    def import_xml path
      parser = Saxerator.parser(File.new(path))

      parser.for_tag(:performer).each do |performer|
        PerformerWorker.perform_later(performer)
      end
    end

    def update_xml path
      parser = Saxerator.parser(File.new(path))

      parser.for_tag(:performer).each do |performer|
        UpdatePerformerWorker.perform_later(performer)
      end
    end

  end

  def initialize performer, event = nil
    @event = event
    if performer.is_a?(Hash)
      @performer_id = performer['id']
      @data = performer
    else
      @performer_id = performer
    end
  end

  def create
    if (@object = ::Performer.where(eventful_id: performer_id).first).present?
      event.performers << @object if event.present? && event.is_a?(Event)

      # Potential update of the performer?
      @object.update_from_eventful(data) if data.present?
    else
      @data = EventfulClient.performer_details(performer_id) unless @data.present?

      @object = ::Performer.create_from_eventful(data, event)
    end

    self
  end

end