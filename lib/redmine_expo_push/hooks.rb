module RedmineExpoPush
  class Hooks < Redmine::Hook::ViewListener

    # TODO it would be nice to have a hook in users/mail_notifications instead.
    render_on :view_my_account_preferences, partial: "hooks/redmine_expo_push/my_account_preferences"
  end
end
