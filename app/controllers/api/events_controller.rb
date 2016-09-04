class Api::EventsController < Api::BaseController
  before_action :check_event_id
  skip_before_action :authenticate_token!, only: [:index, :show]
  before_action :optional_authenticate_token!, only: [:index, :show]

  before_action :find_event, except: [:index, :create, :user_saved, :user_hidden, :update]
  before_action :check_kind_presence, only: [:save, :hide]
  before_action :check_date_presence, only: [:save, :saved, :show, :going]
  before_action :check_starts_at, only: [:create]

  before_action :prepare_photo_ids, only: [:add_photos, :remove_photos]
  before_action :ensure_locations_exist, only: [:create]


  def index
    if user_signed_in? && params[:show_user_events]
      events = current_user
                .events.upcoming.includes(:venue, :photos)
                .include_latest_timetable
                .page(params[:page] || 0).per(30)

      respond_with_data({events: events})
    else
      if %w(latitude longitude).all? {|s| params[s].present? }
        options = {
          date: params[:date],
          page: params[:page] || 1
        }

        events = Event.get_for_pos(params[:latitude], params[:longitude], options)

        pos = PointOfInterest.build_objects(events)

        respond_with_data({events: events}, {
          current_page: params[:page] || 0,
          total_pages: events.total_pages,
          total_count: events.total_count
        })
      else
        respond_with_failure "Params missing or invalid, check the documentation"
      end
    end
  end

  def show

    if params[:latitude].present? && params[:longitude].present?
      coordinates = []
      coordinates << params[:latitude]
      coordinates << params[:longitude]
    end

    respond_with_data(event: EventPresenter.prepare_with_date(@event, current_user, @date, coordinates))
  end

  def create
    @event = Event.create_for_user(event_params, current_user)

    if @event.persisted?
      PointOfInterest.build_objects([@event])
      respond_with_data({event: EventPresenter.prepare_with_date(@event, current_user)})
    else
      respond_with_failure @event.errors.full_messages
    end
  end

  def update
    @event = Event.find(params[:id])

    #only admin users and user that created the event can update the event
    if current_user.admin? || current_user.id == @event.user_id

      if @event.update_for_user(event_params, current_user)
        respond_with_data({event: EventPresenter.prepare_with_date(@event, current_user)})
      else
        respond_with_failure(@event.errors.full_messages.to_sentence)
      end
    else
      respond_with_failure "You're not authorized to update this event."
    end
  end

  def destroy
    @event.destroy
    respond_ok
  end

  def saved
    @saved_friends = @event.saved_friends(current_user, @date).
                     page(params[:page]).per(30)

    respond_with_data({
      saved_count: @event.saved_count(@date),
      friends_saved_count: @saved_friends.total_count,
      users: @saved_friends.map(&:short_presenter)
    }, {
      current_page: params[:page] || 1,
      total_pages: @saved_friends.total_pages,
      total_count: @saved_friends.total_count
    })
  end

  def going
    @attending_friends = @event.attending_friends(current_user, @date).
                     page(params[:page]).per(30)

    respond_with_data({
      going_count: @event.attending_count(@date),
      friends_going_count: @attending_friends.total_count,
      users: @attending_friends.map(&:short_presenter)
    }, {
      current_page: params[:page] || 1,
      total_pages: @attending_friends.total_pages,
      total_count: @attending_friends.total_count
    })
  end

  def user_saved
    respond_with_data(events: current_user.saved_events)
  end

  def user_hidden
    respond_with_data(events: current_user.hidden_events.upcoming.uniq)
  end

  def hidden
    respond_with_data(users: @event.hidden_for_users.map(&:short_presenter))
  end

  def add_photos
    if @ids.present?
      @ids.each { |id| @event.photos << id }

      respond_with_data(event: EventPresenter.prepare_with_date(@event, current_user))
    else
      respond_with_failure "Photo id param(s) is missing"
    end
  end

  def remove_photos
    if @ids.present?
      @ids.each do |id|
        photo = if current_user == @event.user
          Photo.find(id)
        else
          current_user.photos.find(id)
        end

        @event.photos.delete(photo)
      end

      respond_with_data(event: EventPresenter.prepare_with_date(@event, current_user))
    else
      respond_with_failure "Photo id param(s) is missing"
    end
  end

  private

  def check_kind_presence
    return if params[:kind].present?

    respond_with_failure "Kind param missing or invalid"
  end

  def event_params
    allowed_fields = %i{
      name
      description
      starts_at
      ends_at
      url
      kind
      friends_can_invite
      clear_tags
      weight
    }
    allowed_fields << {
      location: %i{
        name
        venue_id
        latitude
        longitude
        street_address
        zip_code
        city
        region
        country
        telephone_number
      }
    }
    allowed_fields << {
      tags: [],
      photo_ids: []
    }

    params.require(:event).permit(*allowed_fields)
  end

  def check_event_id
    if !params[:id].present? && params[:event_id].present?
      params[:id] = params[:event_id]
    end
  end

  def find_event
    @event = if %w{create update destroy}.include?(action_name)
      current_user.events.find(params[:id])
    else
      Event.find(params[:id])
    end
  end

  def check_date_presence
    if params[:date].present?
      @date = DateTime.parse(params[:date]).in_time_zone(Time.zone)
    else
      respond_with_failure("Date param is missing.")
    end
  end

  def check_starts_at
    unless event_params[:starts_at].present?
      respond_with_failure("Starts_at param is missing.")
    end
  end

  def prepare_photo_ids
    @ids = [params[:photo_id].to_i] if params[:photo_id].present?
    @ids = params[:photo_ids].map(&:to_i) if params[:photo_ids].present?
  end

  def location_data_present?
    location = event_params[:location]

    location.present? &&
    (%w{latitude longitude}.all?{|k| location[k].present?} || location[:venue_id].present?)
  end

  def ensure_locations_exist
    return if location_data_present?
    respond_with_failure "Missing location parameter"
  end
end
