class Api::SearchesController < Api::BaseController
  RADIUS = "10km"

  before_action :set_attributes

  def show
    if @autocomplete
      data = SearchIndex.autocomplete_search(@scope, @query)
      respond_with_data(data)
    else
      data = SearchIndex.full_text_search(@scope, @query, {
        user: current_user,
        page: params[:page].present? ? params[:page] : 1
      })

      respond_with_data({
        points: PointOfInterest.build_objects(data, current_user)
      })
    end
  end

  private
  def set_attributes
    @scope        = SearchIndex

    @query        = params.require(:query)
    @autocomplete = params[:autocomplete]

    latitude      = params[:latitude]
    longitude     = params[:longitude]

    if latitude.present? && longitude.present?
      @scope = @scope.filter(geo_distance: {distance: RADIUS, location: {lat: latitude, lon: longitude}})
    end
  end

  def collect_records(records)
    {events: [], venues: []}.tap do |result|
      records.each do |record|
        case record
          when Venue
            result[:venues] << VenuePresenter.prepare_with_date(record)
          when Event
            result[:events] << EventPresenter.prepare_with_date(record)
        end
      end
    end


  end
end
