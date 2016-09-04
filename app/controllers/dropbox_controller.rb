class DropboxController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:update]

  def update
    if params[:delta].present?
      Factual::DropboxWorker.perform_later(params[:delta][:user])
    end
  end

  def confirm_token
    render text: params[:challenge]
  end
end
