module RedmineExpoPush
  module Patches
    module UserPatch
      def self.apply
        User.prepend self unless User < self
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
