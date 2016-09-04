class Api::PhotosController < Api::BaseController
  before_action :set_photo, only: [:show, :edit, :update, :destroy, :report]
  skip_before_action :authenticate_token!, only: [:index, :show]
  before_action :optional_authenticate_token!, only: [:index, :show]

  # GET /api/photos.json
  def index
    if user_signed_in?
      @photos = current_user.photos.all
    else
      @photos = []
    end

    respond_with_data({photos: @photos})
  end

  # GET /api/photos/1.json
  def show
    respond_with_data({photo: @photo.as_json})
  end

  # POST /api/photos.json
  def create
    @photo = Photo.create_for_user(photo_params, current_user)

    if @photo.persisted?
      update_photo_objects

      respond_with_data({photo: @photo.as_json}, {status: :created})
    else
      respond_with_failure @photo.errors.full_messages
    end
  end

  # PATCH/PUT /api/photos/1.json
  def update
    if @photo.update(photo_params)
      update_photo_objects

      respond_with_data({photo: @photo.as_json})
    else
      respond_with_failure @photo.errors.full_messages
    end
  end

  # DELETE /api/photos/1.json
  def destroy
    @photo.destroy
    respond_ok
  end

  def report
    current_user.flag(@photo, report_params)

    respond_ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = if params[:action] = 'report'
        Photo.find(params[:id])
      else
        current_user.photos.find(params[:id])
      end
    end

    def update_photo_objects
      if @event_id.present?
        event = Event.find(@event_id)
        @photo.events << event

        if event.read_attribute(:created_by) == Event::CREATED_BY_USER
          poi = PointOfInterest.where("object_id = ? AND object_type = ?", @event_id, "Event").first

          if !poi.nil? && event.photos.present?
            p = event.photos.first
            photo = { :id => p.id, :url => p.url.nil? ? p.file.url : p.url, :kind => p.kind, :caption => p.caption }
            poi.photo = photo
            poi.save
          end
        end

        unless @photo.venue.present?
          @photo.update_attribute :venue, event.venue
        end
      end
      @photo.performers << Performer.find(@performer_id) if @performer_id.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def photo_params
      permitted_fields = %i{file event_id performer_id venue_id latitude longitude caption}

      params.require(:photo).permit(*permitted_fields).tap do |data|
        @event_id = data.delete(:event_id) || params[:event_id]
        @performer_id = data.delete(:performer_id) || params[:performer_id]
      end
    end

    def report_params
      params.permit(:latitude, :longitude)
    end
end
