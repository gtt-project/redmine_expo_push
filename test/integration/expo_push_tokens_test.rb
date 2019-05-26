require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ExpoPushTokensTest < Redmine::ApiTest::Base
  fixtures :users, :email_addresses

  setup do
    @creds = { 'X-Redmine-API-Key' => User.find_by_login('dlopper').api_key }
    @payload = <<-JSON
    { "token": "asdf1234" }
    JSON
  end

  test 'should require logged user' do
    assert_no_difference "ExpoPushToken.count" do
      post "/expo_push_tokens.json",
        params: @payload,
        headers: {"CONTENT_TYPE" => 'application/json'}
      assert_response 401
    end
  end

  test 'should create token' do
    assert_difference "ExpoPushToken.count" do
      post "/expo_push_tokens.json",
        params: @payload,
        headers: {"CONTENT_TYPE" => 'application/json'}.merge(@creds)
      assert_response 201
    end
  end

  test 'should require token' do
    assert_no_difference "ExpoPushToken.count" do
      post "/expo_push_tokens.json",
        params: %[{"token": ""}],
        headers: {"CONTENT_TYPE" => 'application/json'}.merge(@creds)
      assert_response 422

      post "/expo_push_tokens.json",
        params: %[{}],
        headers: {"CONTENT_TYPE" => 'application/json'}.merge(@creds)
      assert_response 422
    end
  end
end
