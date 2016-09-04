class Api::TastesController < Api::BaseController
  before_action :set_taste, only: [:create]
  before_action :set_user_taste, only: [:destroy]
  before_action :check_location, only: [:index]
  before_action :load_zone, only: [:index]
  before_action :check_taste_ids, only: [:update_user_tastes]

  def index
    @tastes = Taste.tastes_by_category(@zone)

    respond_with_data(tastes: @tastes)
  end

  def user_tastes
    respond_with_data(tastes: current_user.user_tastes)
  end

  def update_user_tastes
    current_user.taste_ids = params[:taste_ids]

    respond_with_data(tastes: current_user.user_tastes)
  end

  def create
    current_user.user_tastes.create({
      taste: @taste,
      score: params[:score] || 1.0
    })
    respond_ok
  end

  def destroy
    @user_taste.destroy
    respond_ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taste
       @taste = Taste.find(params[:id])
    end

    def check_taste_ids
      unless params[:taste_ids].present?
        respond_with_failure('Missing list for taste ids')
      end
    end

    def set_user_taste
      @user_taste = current_user.user_tastes.find_by(taste_id: params[:id])
      unless @user_taste.present?
        respond_with_failure('Could not find taste for user')
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def taste_params
      params[:taste]
    end

    def check_location
      unless %w(latitude longitude).all? {|s| params[s].present? }
        respond_with_failure('Missing latitude and longitude values')
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

end
