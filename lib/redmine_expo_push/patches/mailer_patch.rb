module RedmineExpoPush
  module Patches
    module MailerPatch

      def self.apply
        unless Mailer < InstanceMethods
          Mailer.prepend InstanceMethods
          Mailer.class_eval do
            class << self
              prepend ClassMethods
            end
          end
        end
      end

      module InstanceMethods
        def mail(headers={}, &block)
          if @expo_push_override_subject
            headers[:subject] = @expo_push_override_subject
          end
          super
        end

        def news_added(user, news)
          @expo_push_override_subject = news.title
          super
        end

        def issue_edit(user, journal)
          if journal.new_value_for('status_id')
            # TODO move static text to locale files?
            @expo_push_override_subject = "レポート：[ #{journal.journalized.subject} ] の対応状況が更新されました"
          end
          super
        end
      end

      module ClassMethods

        def deliver_mail(mail, &block)
          if perform_deliveries
            notification = nil
            %i(to cc bcc).each do |field|
              receivers = Array(mail.send(field)).flatten.compact
              skip_receivers = []
              receivers.each do |addr|
                user = User.having_mail(addr).first
                if user.present? and user.send_push_notifications?
                  notification ||= RedmineExpoPush::Notification.for(mail)
                  notification.add_recipient user
                  skip_receivers << addr if user.push_skip_emails?
                end
              end
              mail.send "#{field}=", (receivers - skip_receivers)
            end
            notification.deliver if notification
          end

          super
        end

      end

    end
  end
end

