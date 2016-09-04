class PostsCacheService

	POST_CACHE_EXPIRATION = {
		:posts_index_by_location => 1,
		:posts_index_public => 1,
		:posts_index_user_public => 1,
		:posts_index_user_related_object => 1,
		:posts_index_user_by_location => 1,
		:posts_index_related_objects_public => 1
	}

	def self.index(params, related_object, user)

		if user

			if related_object.present?
				user_posts = $redis_cache.get("posts_index_user_#{user.id}_#{related_object.class}_id_#{related_object.id}")

				if user_posts.nil?
					user_posts = related_object.posts.includes(:source)
					user_posts = user_posts.filter_out_reported(user.reported_posts) if user.reported_posts.size > 0
					user_posts = user_posts.filter_out_blocked_users(user.blocked_users) if user.blocked_users.size > 0
					user_posts = user_posts.order(created_at: :desc).page(params[:page] || 1).per(30)

					if user_posts.present?
						$redis_cache.set("posts_index_user_#{user.id}_#{related_object.class}_id_#{related_object.id}", user_posts.to_json)
						$redis_cache.expire("posts_index_user_#{user.id}_#{related_object.class}_id_#{related_object.id}", POST_CACHE_EXPIRATION[:posts_index_user_related_object].minutes.to_i)
					end
				end

				user_posts
			elsif params[:latitude].present? && params[:longitude].present?

				prepare_coordinates(params)

				user_posts_by_location = $redis_cache.get("posts_index_user_#{user.id}_by_location_#{@lat}_#{@lon}")

				if user_posts_by_location.nil?

					user_posts_by_location = params[:radius].present? ? Post.get_by_location(params[:latitude], params[:longitude], params[:radius]).includes(:source) : Post.get_by_location(params[:latitude], params[:longitude]).includes(:source)
					user_posts_by_location = user_posts_by_location.filter_out_reported(user.reported_posts) if user.reported_posts.size > 0
					user_posts_by_location = user_posts_by_location.filter_out_blocked_users(user.blocked_users) if user.blocked_users.size > 0
					user_posts_by_location = user_posts_by_location.order(created_at: :desc).page(params[:page] || 1).per(30)

					if user_posts_by_location.present?
						$redis_cache.set("posts_index_user_#{user.id}_by_location_#{@lat}_#{@lon}", user_posts_by_location.to_json)
						$redis_cache.expire("posts_index_user_#{user.id}_by_location_#{@lat}_#{@lon}", POST_CACHE_EXPIRATION[:posts_index_user_by_location].minutes.to_i)
					end
				end

				user_posts_by_location
			else
				user_public_posts = $redis_cache.get("posts_index_user_#{user.id}_public")

				if user_public_posts.nil?
					user_public_posts = Post.public_only.recent.includes(:source)
					user_public_posts = user_public_posts.filter_out_reported(user.reported_posts) if user.reported_posts.size > 0
					user_public_posts = user_public_posts.filter_out_blocked_users(user.blocked_users) if user.blocked_users.size > 0
					user_public_posts = user_public_posts.order(created_at: :desc).page(params[:page] || 1).per(30)

					if user_public_posts.present?
						$redis_cache.set("posts_index_user_#{user.id}_public", user_public_posts.to_json)
						$redis_cache.expire("posts_index_user_#{user.id}_public", POST_CACHE_EXPIRATION[:posts_index_user_public].minutes.to_i)
					end
				end

				user_public_posts
			end

		else

			if related_object.present?
				related_object_public_posts = $redis_cache.get("posts_index_#{related_object.class}_#{related_object.id}")

				if related_object_public_posts.nil?
					related_object_public_posts = related_object.posts.includes(:source).order(created_at: :desc).page(params[:page] || 1).per(30)

					if related_object_public_posts.present?
						$redis_cache.set("posts_index_#{related_object.class}_#{related_object.id}", related_object_public_posts.to_json)
						$redis_cache.expire("posts_index_#{related_object.class}_#{related_object.id}", POST_CACHE_EXPIRATION[:posts_index_related_objects_public].minutes.to_i)
					end
				end

				related_object_public_posts
			elsif params[:latitude].present? && params[:longitude].present?

				prepare_coordinates(params)

				posts_by_location = $redis_cache.get("posts_index_by_location_#{@lat}_#{@lon}")

				if posts_by_location.nil?

					posts_by_location = params[:radius].present? ? Post.get_by_location(params[:latitude], params[:longitude], params[:radius]) : Post.get_by_location(params[:latitude], params[:longitude])
					posts_by_location = posts_by_location.includes(:source).order(created_at: :desc).page(params[:page] || 1).per(30)

					if posts_by_location.present?
						$redis_cache.set("posts_index_by_location_#{@lat}_#{@lon}", posts_by_location.to_json)
						$redis_cache.expire("posts_index_by_location_#{@lat}_#{@lon}", POST_CACHE_EXPIRATION[:posts_index_by_location].minutes.to_i)
					end
				end

				posts_by_location
			else
				public_recent_posts = $redis_cache.get("posts_index_public")

				if public_recent_posts.nil?
					public_recent_posts = Post.public_only.recent.includes(:source).order(created_at: :desc).page(params[:page] || 1).per(30)

					if public_recent_posts.present?
						$redis_cache.set("posts_index_public", public_recent_posts.to_json)
						$redis_cache.expire("posts_index_public", POST_CACHE_EXPIRATION[:posts_index_public].minutes.to_i)
					end
				end

				public_recent_posts
			end
		end
	end


	def self.prepare_coordinates(params)
		@lat = params[:latitude]
		@lon = params[:longitude]

		@lat = @lat[0..@lat.index('.') + 3]
		@lon = @lon[0..@lat.index('.') + 3]
	end

end
