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

    # https://docs.expo.io/push-notifications/sending-notifications/
    # https://github.com/expo/expo-server-sdk-ruby
    # https://docs.expo.io/push-notifications/sending-notifications/#message-request-format
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
        messages.each_slice(100) {|message_list|
          begin
            handler = Exponent::Push::Client.new(gzip: true).send_messages message_list
            if handler.errors.present?
              Rails.logger.error "handler.errors:#{handler.errors}"
            end
            if handler.receipt_ids.present?
              Rails.logger.info "handler.receipt_ids:#{handler.receipt_ids}"
            end
          rescue Exception
            Rails.logger.error "error sending push notifications:\n#{$!}\n" + $!.backtrace.join("\n")
          end
        }
      end
    end
  end
end
