class Api::ExploreController < Api::BaseController
  before_action :check_date_presence, only: [:index, :save, :hide, :invite, :going]
  before_action :load_object, only: [:save, :hide, :invite, :going]
  before_action :load_friend, only: [:invite]
  before_action :verify_object, only: [:going]
  before_action :check_vote, only: [:vote]
  before_action :load_zone, only: [:recommendation]

  def index
    if %w(latitude longitude).all? {|s| params[s].present? }
      options = {
        date: @date,
        page: params[:page] || 1,
        events_per_page: 5,
        venues_per_page: 5,
        per_page: 10,
        user: current_user
      }

      # Fetch events.
      events = PointOfInterest.explore_events(params[:latitude],
                                     params[:longitude],
                                     options)

      # If there are less events than specified, load more venues.
      if events.length < (options[:per_page].to_i / 2)
        options[:venues_per_page] = (options[:per_page].to_i - events.length)
      end

      # Fetch venues.
      venues = PointOfInterest.explore_venues(params[:latitude],
                                     params[:longitude],
                                     options)

      total_count = events.total_count + venues.total_count
      total_pages = events.total_pages >= venues.total_pages ? events.total_pages : venues.total_pages


      events = events.to_a
      venues = venues.to_a

      events_venues_sorted = []
      events_venues_sorted << (events.any? ? events.shift : (venues.any? ? venues.shift : nil))

      if events_venues_sorted.first.nil?
        respond_with_failure("No data to show.")
        return
      else
        loop_count = events.length + venues.length
        for i in 0...loop_count
          if events.length > 0
            if events_venues_sorted.last.object_type != "Event"
              events_venues_sorted << events.shift
            else
              if venues.length > 0
                events_venues_sorted << venues.shift
              else
                events_venues_sorted << events.shift
              end
            end
          else
            events_venues_sorted += venues
            break
          end
        end
      end

      pois = PointOfInterest.process_objects(events_venues_sorted, options)

      respond_with_data({points: pois}, {
        current_page: options[:page],
        total_pages: total_pages,
        total_count: total_count
      })
    else
      respond_with_failure "Params missing or invalid, check the documentation"
    end
  end

  def recommend
    options = {
      date: @date,
      page: params[:page] || 1,
      per_page: 50,
      user: current_user
    }

    venues = PointOfInterest.recommend_venues(@zone,
                                   options)
    events = PointOfInterest.recommend_events(@zone,
                                   options)

    pois = PointOfInterest.process_objects(events + venues, options)

    respond_with_data({points: pois}, {
      current_page: options[:page],
      total_pages: venues.total_pages,
      total_count: venues.total_count + events.total_count
    })
  end

  def saved
    options = {
      page: params[:page] || 1,
      per_page: params[:per_page] || 30
    }

    respond_with_data(current_user.saved_poi(options))
  end

  def save
    if params[:kind] == 'save'
      @object.save_for_user(current_user, @date)
    elsif params[:kind] == 'remove'
      @object.remove_for_user(current_user, @date)
    end

    respond_ok
  end

  def going
    if params[:kind] == 'going'
      @object.attend_for_user(current_user, @date)
    elsif params[:kind] == 'not_going'
      @object.not_attending_for_user(current_user, @date)
    elsif params[:kind] == 'pending'
      @object.remove_attend_for_user(current_user, @date)
    end

    respond_ok
  end

  def hide
    if params[:kind] == 'hide'
      @object.hidden_for_users << current_user
    elsif params[:kind] == 'unhide'
      @object.hidden_for_users.delete(current_user)
    end

    respond_ok
  end

  def vote
    case @vote
    when "like"
      @object.liked_by(current_user)
    when "dislike"
      @object.disliked_by(current_user)
    when "pending"
      @object.unliked_by(current_user)
    end

    respond_ok
  end

  def invite
    options = {
      invite_at: @date
    }

    if (invitation = current_user.invite_friend(@friend, @object, options))
      respond_with_data(invitation: invitation)
    else
      respond_with_failure(invitation.errors.full_messages)
    end
  end

  private

  def check_vote
    if params[:vote].present? &&
       %w{like dislike pending}.any?{|word| word == params[:vote]}

      @vote = params[:vote]

      if %w{Venue Event Post}.include?(params[:object_type])
        klass = params[:object_type].constantize

        @object = klass.find(params[:object_id])
      else
        respond_with_failure("object_type param is missing.")
      end

    else
      respond_with_failure "Vote param missing or invalid"
    end
  end

  def check_date_presence
    if params[:date].present?
      @date = Time.zone.parse(params[:date]).
                       change(offset: UserAction.get_offset_string).
                       in_time_zone(Time.zone)
    else
      respond_with_failure("Date param is missing.")
    end
  end

  def load_friend
    if params[:friend_id].present?
      @friend = current_user.friends.find(params[:friend_id])
    else
      respond_with_failure("friend_id param is missing.")
    end
  end

  def load_object
    if %w{Venue Event}.include?(params[:object_type])
      klass = params[:object_type].constantize

      @object = klass.find(params[:object_id])
    else
      respond_with_failure("object_type param is missing.")
    end
  end

  def load_zone
    if %w(latitude longitude).all? {|s| params[s].present? }
      @zone = City.nearest_city(params[:latitude], params[:longitude])

      unless @zone.present?
        respond_with_failure "You are not near any City that we do recommendations for"
      end
    else
      respond_with_failure "Params missing or invalid, check the documentation"
    end
  end

  def verify_object
    unless @object.is_a?(Event)
      respond_with_failure("Going action works only with Event")
    end
  end
end
