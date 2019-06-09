require_relative "../test_helper"

class UserTest < ActiveSupport::TestCase
  fixtures :users, :user_preferences, :email_addresses

  setup do
    @user = User.find_by_login "jsmith"
  end

  test "should default to no push notifs" do
    refute @user.send_push_notifications?
    refute @user.push_skip_emails?
  end

  test "user with token should default to push no email" do
    @user.expo_push_tokens.create! token: "foo"
    assert @user.send_push_notifications?
    assert @user.push_skip_emails?
  end

end
