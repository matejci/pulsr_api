class Api::PostsController < Api::BaseController
  skip_before_action :authenticate_token!, only: [:index, :show]
  before_action :optional_authenticate_token!, only: [:index, :show]
  before_action :set_related_object
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts.json
  def index
    cache_result = PostsCacheService.index(params, @related_object, user_signed_in? ? current_user : false)
    cache_result = JSON.parse(cache_result) if cache_result.is_a?(String)
    cache_result = cache_result.map(&:as_json)
    respond_with_data(posts: cache_result)
  end

  # GET /posts/1.json
  def show
    respond_with_data(post: @post)
  end

  # POST /posts.json
  def create
    @post = Post.create_user_post(post_params, current_user)

    if @post.persisted?
      respond_with_data({post: @post}, {status: :created})
    else
      respond_with_failure @post.errors.full_messages
    end
  end

  # PATCH/PUT /posts/1.json
  def update
    if @post.update_with_photo(post_params)
      respond_with_data(post: @post)
    else
      respond_with_failure @post.errors.full_messages
    end
  end

  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_ok
  end

  # PUT /posts/1/report.json
  def report
    current_user.reported_posts << params[:id]
    current_user.reported_posts.uniq!
    current_user.save

    ReportService.send_report_email(params[:id], current_user.id)

    @posts = Post.public_only.recent.includes(:source).filter_out_reported(current_user.reported_posts)
    @posts = @posts.filter_out_blocked_users(current_user.blocked_users) if current_user.blocked_users.size > 0
    @posts = @posts.order(created_at: :desc).page(params[:page] || 1).per(30)
    posts_json = @posts.map {|post| post.as_json_for_user(current_user)}
    respond_with_data(posts: posts_json)
  end

  private
    def assign_related_object
      if @related_object.present? && !@related_object.is_a?(User)
        @related_object
      end
    end

    def set_related_object
      %w{venue event performer user}.each do |object|
        if params["#{object}_id"].present?
          @related_object = object.capitalize.constantize.find(params["#{object}_id"])
        end
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = if %w{create update destroy}.include?(action_name)
        current_user.posts.find(params[:id])
      else
        Post.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      allowed_fields = %i{photo_id photo_file body latitude longitude remarks location_name address}
      params.require(:post).permit(*allowed_fields).tap do |data|
        data[:item] = assign_related_object
      end
    end
end
