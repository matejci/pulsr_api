class Api::InvitationsController < Api::BaseController
  before_action :check_contacts, only: [:create]
  before_action :check_invitable, only: [:create]
  before_action :verify_date, only: [:create]

  def create
    current_user.invite_contacts(@contacts, invitation_options)
    respond_ok
  end

  private

  def invitation_options
    {}.tap do |options|
      options[:invitable] = @invitable if @invitable.present?
      options[:invite_at] = @date if @date.present?
      options[:branch_url] = params[:branch_url]
    end
  end

  def check_contacts
    if params[:contact].present?
      @contacts = [params[:contact]]
    elsif params[:contacts].present?
      @contacts = params[:contacts]
    elsif params[:contact_list].present?
      @contacts = params[:contact_list]
    else
      respond_with_failure("You need to provide contacts to invite to")
    end
  end

  def check_invitable
    if %i{invitable_id invitable_type}.all?{|key| params[key].present?}

      if params[:invitable_type] == 'Event'
        if params[:date].present?
          @invitable = Event.find(params[:invitable_id])
          @date = params[:date]
        else
          respond_with_failure "You need to provide a date"
        end
      elsif params[:invitable_type] == 'Venue'
        if params[:date].present?
          @invitable = Venue.find(params[:invitable_id])
          @date = params[:date]
        else
          respond_with_failure "You need to provide a date"
        end
      else
        respond_with_failure "You don't have the right invitable_type"
      end

    end
  end

  def verify_date
    if @invitable.is_a?(Event)
      unless @invitable.timetables.for_date(@date).present?
        respond_with_failure "Event doesn't have this date as available"
      end
    end
  end
end
