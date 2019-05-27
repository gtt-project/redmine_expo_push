module RedmineExpoPush
  module Patches
    # this is a draft, just in case we want to add general push notification
    # support for all redmine notifications
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
                if user.present?
                  cfg = RedmineExpoPush::UserConfig.new(user)
                  if cfg.send_push_notifications?
                    notification ||= Notification.new(mail)
                    notification.add_recipient user
                    skip_receivers << addr if cfg.skip_emails?
                  end
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

