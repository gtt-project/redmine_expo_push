module RedmineExpoPush
  class Notification
    attr_reader :title, :body, :data

    def initialize(title: nil, body: nil, data: {})
      @title = title
      @body = body
      @data = data
      @recipients = []
    end

    def self.for(email)
      new title: email.subject, body: email.text_part&.body&.decoded
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
            to: token.token,
            title: @title,
            body: @body,
            data: @data
          }
        end
      end
      messages.flatten!

      if messages.any?
        begin
          Exponent::Push::Client.new(gzip: true).publish messages
        rescue Exception
          Rails.logger.error "error sending push notifications:\n#{$!}\n" + $!.backtrace.join("\n")
        end
      end
    end
  end
end
