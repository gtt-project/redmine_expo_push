# frozen_string_literal: true

module RedmineExpoPush
  module Patches
    module UserPatch
      def self.apply
        unless User < self
          User.prepend self
          User.class_eval do
            has_many :expo_push_tokens
          end
        end
      end

      def push_device_registered?
        expo_push_tokens.any?
      end

      def send_push_notifications?
        pref.push_notifications != "disabled"
      end

      def push_skip_emails?
        # only skip emails when at least one device is registered
        pref.push_notifications == "enabled_no_email"
      end

      def remove_references_before_destroy
        super
        if self.id
          ExpoPushToken.where(user_id: id).delete_all
        end
      end
    end
  end
end
