module RedmineExpoPush
  class Notification
    def initialize(title: nil, body: nil, data: {})
      @title = title
      @body = body
      @data = data
      @recipients = []
    end

    def add_recipient(user)
      @recipients << user
    end

    # https://docs.expo.io/versions/latest/guides/push-notifications/
    # https://github.com/expo/expo-server-sdk-ruby
    # https://docs.expo.io/versions/latest/guides/push-notifications/#message-format
    def deliver
      messages = @recipients.map do |user|
        ExpoPushToken.where(user: user).map do |token|
          {
            to: token,
            title: @title,
            body: @body,
            data: @data
          }
        end
      end
      messages.flatten!

      Exponent::Push::Client.new(gzip: true).publish messages
    end
  end
end
