require_relative "../test_helper"

class NotificationTest < ActiveSupport::TestCase
  fixtures :users, :user_preferences, :email_addresses, :projects, :news

  setup do
    @user = User.find_by_login "jsmith"
    @news = News.find 1
    (@emails = ActionMailer::Base.deliveries).clear
  end

  test "should build notification from email" do
    mail = Mailer.news_added @user, @news
    assert n = RedmineExpoPush::Notification.for(mail)
    assert_equal "[#{@news.project.name}] #{I18n.t(:label_news)}: #{@news.title}",
      n.title
    assert_match(/released/, n.body)
  end

  test "should send notification instead of email" do
    Exponent::Push::Client.any_instance.expects(:publish)

    # no token, email is sent
    mail = Mailer.news_added @user, @news
    mail.deliver
    assert_equal 1, @emails.size

    @emails.clear
    @user.expo_push_tokens.create! token: "foo"

    # token is set, push notification but no email is sent
    mail = Mailer.news_added @user, @news
    mail.deliver
    assert @emails.blank?, @emails.inspect
  end

  test "should send notification and email" do
    Exponent::Push::Client.any_instance.expects(:publish)

    @user.expo_push_tokens.create! token: "foo"
    @user.pref.push_notifications = "enabled"
    @user.pref.save

    # token is set, push notification but no email is sent
    mail = Mailer.news_added @user, @news
    mail.deliver
    assert_equal 1, @emails.size
  end


end
