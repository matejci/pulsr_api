class Api::VenuesController < Api::BaseController
  before_action :check_venue_id
  skip_before_action :authenticate_token!, only: [:index, :show]
  before_action :optional_authenticate_token!, only: [:index, :show]

  before_action :find_venue, except: [:index, :create]
  before_action :check_kind_presence, only: [:save, :hide]
  before_action :check_date_presence, only: [:save, :saved, :show]

  before_action :prepare_photo_ids, only: [:add_photos, :remove_photos]

  def index
  end

  def show
    if params[:latitude].present? && params[:longitude].present?
      coordinates = []
      coordinates << params[:latitude]
      coordinates << params[:longitude]
    end

    respond_with_data(venue: VenuePresenter.prepare_with_date(@venue, current_user, @date, coordinates))
  end

  def saved
    @saved_friends = @venue.saved_friends(current_user, @date).
                     page(params[:page]).per(30)

    respond_with_data({
      saved_count: @venue.saved_count(@date),
      friends_saved_count: @saved_friends.total_count,
      users: @saved_friends.map(&:short_presenter)
    }, {
      current_page: params[:page] || 1,
      total_pages: @saved_friends.total_pages,
      total_count: @saved_friends.total_count
    })
  end

  def update
    if current_user.admin?

      params[:venue][:user_id] = current_user.id

      if @venue.update venue_params
        respond_with_data venue: @venue
      else
        respond_with_failure @venue.errors.full_messages.to_sentence
      end
    else
      respond_with_failure "You're not authorized to update this venue."
    end
  end

  def hidden
    respond_with_data(users: @venue.hidden_for_users.map(&:short_presenter))
  end

  def add_photos
    if @ids.present?
      @ids.each { |id| @venue.photos << id }

      respond_with_data(venue: VenuePresenter.prepare_with_user(@venue))
    else
      respond_with_failure "Photo id(s) param is missing"
    end
  end

  def remove_photos
    if @ids.present?
      @ids.each do |id|
        photo = if current_user == @venue.user
          Photo.find(id)
        else
          current_user.photos.find(id)
        end

        @venue.photos.delete(photo)
      end

      respond_with_data(venue: VenuePresenter.prepare_with_user(@venue))
    else
      respond_with_failure "Photo id(s) param is missing"
    end
  end

  private

  def check_venue_id
    if !params[:id].present? && params[:venue_id].present?
      params[:id] = params[:venue_id]
    end
  end

  def prepare_photo_ids
    @ids = [params[:photo_id].to_i] if params[:photo_id].present?
    @ids = params[:photo_ids].map(&:to_i) if params[:photo_ids].present?
  end

  def check_date_presence
    if params[:date].present?
      @date = DateTime.parse(params[:date]).in_time_zone(Time.zone)
    else
      respond_with_failure("Date param is missing.")
    end
  end

  def check_kind_presence
    return if params[:kind].present?

    respond_with_failure "Kind param missing or invalid"
  end

  def find_venue
    @venue = Venue.find(params[:id])
  end

  def venue_params
    allowed_fields = %i{
      name
      description
      category
      street_address
      city
      region
      zip_code
      country
      time_zone
      latitude
      longitude
      images
      telephone_number
      links
      email
      cuisine
      hours
      factual_id
      short_factual_id
      created_by
      factual_rating
      factual_price
      processed_at
      twitter
      data
      url
      factual_existence
      pending_at
      instagram_at
      location
      user_id
    }
    params.require(:venue).permit(*allowed_fields)
  end
end
