module MailerHelper

  def get_invite_from_friend_message(notification, type)
    message = get_invitation_message(notification, type)

    content_tag :p, class: "#{type}-message" do
      content_tag(:strong, notification.get_sender_display_name) +
      " " +
      message
    end
  end

  def get_email_deeplink_url(notification)
    notification.object.full_branch_url.nil? ? "www.pulsr.com" : notification.object.full_branch_url
  end

  def get_invitation_message(notification, type)
    taste_title = Taste.get_users_taste(notification.get_sender).try(:title)

    case type
    when 'onboarding_invite'
      "says you two often go to #{taste_title}. Check out these cool #{taste_title}:"
    when 'friend_invite'
      "is using a hot new app called Pulsr to find great #{taste_title} around town, and they've invited you to check it out!"
    when 'event_invite'
      event_name = notification.object.invitable.try(:name)
      "has invited you to #{event_name}. Check it out on Pulsr!"
    else
      ''
    end
  end

  def get_app_button_text(type)
    type == 'friend_invite' ? 'Get Pulsr Now' : 'Open Pulsr'
  end

  def get_header_graphics_image(type)
    image_url = "mailers/onboarding_friendship/"
    image_url << (('onboarding_invite' == type) ? "pulsr-onboard-multi.jpg" : "pulsr-invite-envelope.png")
    image_url
  end
end