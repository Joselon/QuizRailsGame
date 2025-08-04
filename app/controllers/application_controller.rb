class ApplicationController < ActionController::Base
 before_action :configure_permitted_parameters, if: :devise_controller?
 before_action :track_user_activity
 before_action :store_current_user_id, if: -> { controller_name == "sessions" && action_name == "destroy" }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def store_current_user_id
    session[:last_user_id] = current_user&.id
  end

  def after_sign_in_path_for(resource)
    broadcast_update_users_online
    super
  end

  def after_sign_out_path_for(resource_or_scope)
    user_id = session.delete(:last_user_id)
    AppRedisClient.instance.redis.del("user:#{user_id}:online")
    broadcast_update_users_online

    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  private

  def track_user_activity
    return unless user_signed_in?

    now = Time.current
    user_key = "user:#{current_user.id}:online"
    redis = AppRedisClient.instance.redis
    previously_online = redis.exists(user_key)

    redis.setex(user_key, 10.minutes.to_i, now.to_s)

    if current_user.last_seen_at.nil? || current_user.last_seen_at < 5.minutes.ago
      current_user.update_column(:last_seen_at, now)
    end

    unless previously_online
      broadcast_update_users_online
    end
  end
  def broadcast_update_users_online
    Turbo::StreamsChannel.broadcast_replace_to(
      "online_users",
      target: "online_users",
      partial: "online_users/count"
    )
  end
end
