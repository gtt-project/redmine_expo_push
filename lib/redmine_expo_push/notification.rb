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
            if message_list.length == 0
              next
            end
            tokens = message_list.map {|message|
              message[:to]
            }
            Rails.logger.info "tokens: #{tokens}"
            handler = Exponent::Push::Client.new(gzip: true).send_messages message_list
            if handler.errors.present?
              Rails.logger.error "handler.errors: #{handler.errors}"
            end
            if handler.receipt_ids.present?
              Rails.logger.info "handler.receipt_ids: #{handler.receipt_ids}"
            end
          rescue Exception => e
            Rails.logger.error "error sending push notifications: #{e}"
            if e.message.present? and e.message.start_with?("Unknown error format: ") \
                and Setting.plugin_redmine_expo_push['experience_id'].present?
              # https://github.com/expo/expo/issues/6771#issuecomment-780095144
              begin
                response = JSON.parse(e.message.sub(/^Unknown error format: /, ''))
                error = response.fetch("errors").first
                code = error.fetch("code")
                if code == "PUSH_TOO_MANY_EXPERIENCE_IDS"
                  Rails.logger.info "retrying to send messages"
                  message = error.fetch("message")
                  details = error.fetch("details")
                  details.keys.each {|key|
                    if key != Setting.plugin_redmine_expo_push['experience_id']
                      details[key].each {|token|
                        message_list.reject! {|message|
                          message[:to] == token
                        }
                      }
                    end
                  }
                  # Retry with cleaned up message_list
                  retry
                end
              rescue Exception => e2
                Rails.logger.info "retrying to send messages failed: #{e2}"
              end
            end
          end
        }
      end
    end
  end
end
