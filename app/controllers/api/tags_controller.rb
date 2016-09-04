class Api::TagsController < Api::BaseController
  before_action :set_tag, only: [:show, :add, :remove]
  before_action :set_related_object, only: [:add, :remove]
  before_action :check_related_object, only: [:index]
  skip_before_action :authenticate_token!, only: [:index, :show]

  # GET /api/tags.json
  def index
    @tags = if @related_object.present?
      @related_object.tags
    else
      Tag.all
    end

    if params[:query].present?
      @tags = @tags.query_by_name(params[:query])
    end

    @tags = @tags.page(params[:page] || 0).per(30)

    respond_with_data({tags: @tags})
  end

  # GET /api/tags/1.json
  def show
    respond_with_data({tag: @tag.as_json})
  end

  def add
    @related_object.tags << @tag

    respond_ok
  end

  def remove
    @related_object.tags.delete(@tag)

    respond_ok
  end

  private
    def set_tag
      @tag = Tag.find(params[:id])
    end

    def set_related_object
      unless %i{venue_id event_id performer_id}.one? {|item| params[item].present? }
        respond_with_failure "Too many parameters, send only one related object, venue, event or performer"
      end

      @related_object = current_user.venues.find(params[:venue_id]) if params[:venue_id].present?
      @related_object = current_user.events.find(params[:event_id]) if params[:event_id].present?
      @related_object = current_user.performers.find(params[:performer_id]) if params[:performer_id].present?
    end

    def check_related_object
      @related_object = Venue.find(params[:venue_id]) if params[:venue_id].present?
      @related_object = Event.find(params[:event_id]) if params[:event_id].present?
      @related_object = Performer.find(params[:performer_id]) if params[:performer_id].present?
    end
end
