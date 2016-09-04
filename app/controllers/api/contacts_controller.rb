class Api::ContactsController < Api::BaseController
  before_action :check_valid_data, only: [:check]

  def index
    contacts = current_user.get_latest_contact_list

    FriendsStatisticsService.append!(contacts, current_user, :user_id)

    respond_with_data(contacts: contacts)
  end

  def check
    if @device_id.present?
      contact_book.prepare_import(@contact_list, @device_id)
    else
      contact_book.prepare_import(@contact_list)
    end

    respond_ok
  end

  private

  def contact_book
    @contact_book ||= current_user.contact_book
  end

  def check_valid_data
    if params[:contact_list].present?
      @contact_list = params[:contact_list]
      @contact_list = [@contact_list] unless @contact_list.is_a?(Array)
    else
      respond_with_failure("Contact list param is missing")
    end

    @device_id = params[:device_id]
  end
end
