# frozen_string_literal: true

module RedmineExpoPush
  module Patches
    module UserPreferencePatch
      def self.apply
        unless UserPreference < self
          UserPreference.prepend self
          UserPreference.class_eval do
            safe_attributes :push_notifications
          end
        end
      end

      def push_notifications
        self[:push_notifications] || "enabled_no_email"
      end

      def push_notifications=(new_value)
        self[:push_notifications] = new_value
      end

    end
  end
end


