module RedmineExpoPush
  module Patches
    module MailerPatch

      def self.apply
        Mailer.class_eval do
          class << self
            prepend ClassMethods
          end
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
                  if mail.subject == l(:mail_subject_lost_password, Setting.app_title)
                    next
                  end
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

