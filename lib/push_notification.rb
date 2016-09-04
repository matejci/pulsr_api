class PushNotification

  IOS_PUSH_NAME = "ios_app_#{ENV['RAILS_ENV']}"
  ANDROID_PUSH_NAME = "android_app_#{ENV['RAILS_ENV']}"

  class << self
    def setup
      setup_ios
      setup_android
    end

    def setup_ios
      app = Rpush::Apns::App.find_by_name(IOS_PUSH_NAME)

      unless app.present?
        app = Rpush::Apns::App.new
        app.name = IOS_PUSH_NAME
        app.certificate = File.read("#{Rails.root}/config/certs/#{ENV['IOS_PUSH_CERTIFICATE_FILENAME']}")
        app.environment = Rails.env.development? ? "sandbox" : "production" # APNs environment.
        app.password = ENV['IOS_PUSH_PASSWORD']
        app.connections = 2
        app.save!
      end
    end

    def setup_android
      app = Rpush::Gcm::App.find_by_name(ANDROID_PUSH_NAME)

      unless app.present?
        app = Rpush::Gcm::App.new
        app.name = ANDROID_PUSH_NAME
        app.auth_key = ENV['GCM_AUTH_KEY']
        app.connections = 1
        app.save!
      end
    end

    def send_notification_to recipient, notification
      if recipient.can_push_notifications?

        data = notification.push_json
        title = notification.push_title

        recipient.devices.active.each do |device|
          if device.ios?
            send_to_ios device.token, title, data
          elsif device.android?
            send_to_android device.token, title, data
          end
        end
      end
    end

    def send_message recipient, message
      if recipient.can_push_notifications?

        data = {}
        title = message

        recipient.devices.active.each do |device|
          if device.ios?
            send_to_ios device.token, title, data
          elsif device.android?
            send_to_android device.token, title, data
          end
        end
      end
    end

    def send_to_android token, message, data
      n = Rpush::Gcm::Notification.new
      n.app = Rpush::Gcm::App.find_by_name(ANDROID_PUSH_NAME)
      n.registration_ids = [token]
      n.data = data.merge message: message
      n.save!
    end

    def send_to_ios token, alert, data
      n = Rpush::Apns::Notification.new
      n.app = Rpush::Apns::App.find_by_name(IOS_PUSH_NAME)
      n.device_token = token
      n.alert = alert
      n.data = data
      n.save!
    end

    def remove_android_device(token)
      Device.remove_token(token, 'android')
    end

    def remove_ios_device(token)
      Device.remove_token(token, 'ios')
    end
  end
end