class Api::RegistrationController < Devise::RegistrationsController
  include Respondable

  protect_from_forgery with: :null_session
  skip_before_filter :verify_authenticity_token,
                     :if => :json_request?

  respond_to :json

  def create
    if sign_up_params[:phone_number].present?
      self.resource = User.find_unregistered_user(sign_up_params[:phone_number])
    end

    if resource.present?
      sign_up_params[:active] = true
      resource.assign_attributes(sign_up_params)
    else
      build_resource(sign_up_params)
    end
    # resource.skip_confirmation!

    if resource.save
      sign_in(resource)

      respond_with_data({
        user: resource,
        access_token: current_user.get_authentication_token
      }, {info: "Registered", message: "Registered"})
    else
      respond_with_failure resource.errors.full_messages
    end
  end

  protected

  def json_request?
    request.format.json?
  end

end
