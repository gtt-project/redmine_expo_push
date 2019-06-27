require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ExpoPushTokensTest < Redmine::ApiTest::Base
  fixtures :users, :email_addresses

  setup do
    @user = User.find_by_login 'dlopper'
    @jsmith = User.find_by_login 'jsmith'

    @creds = { 'X-Redmine-API-Key' => @user.api_key }
    @jsmith_creds = { 'X-Redmine-API-Key' => @jsmith.api_key }
    @admin_creds = { 'X-Redmine-API-Key' => User.find_by_login('admin').api_key }
    @payload = <<-JSON
    { "token": "asdf1234" }
    JSON

    @user_id_payload = <<-JSON
    { "token": "asdf1234", "user_id": "#{@user.id}" }
    JSON

    @t1 = ExpoPushToken.create! user: @user, token: "asdf.1234"
    @t2 = ExpoPushToken.create! user: User.find_by_login('jsmith'), token: "asdf.1234"
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

  test 'should not create same token twice' do
    assert_difference "ExpoPushToken.count" do
      post "/expo_push_tokens.json",
        params: @payload,
        headers: {"CONTENT_TYPE" => 'application/json'}.merge(@creds)
      assert_response 201
      post "/expo_push_tokens.json",
        params: @payload,
        headers: {"CONTENT_TYPE" => 'application/json'}.merge(@creds)
      assert_response 422
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

  test "should delete tokens of logged user" do
    log_user "dlopper", "foo"
    assert_difference "ExpoPushToken.count", -1 do
      delete "/expo_push_tokens"
    end
    assert_redirected_to "/my/account"

    assert_raise ActiveRecord::RecordNotFound do
      @t1.reload
    end
    @t2.reload
  end

  test "should only delete tokens of logged user" do
    log_user "dlopper", "foo"
    assert_difference "ExpoPushToken.count", -1 do
      delete "/expo_push_tokens", params: { user_id: @jsmith.id }
    end
    assert_redirected_to "/my/account"

    assert_raise ActiveRecord::RecordNotFound do
      @t1.reload
    end
    @t2.reload
  end

  test "admin should be able to delete tokens of other user" do
    log_user "admin", "admin"
    assert_difference "ExpoPushToken.count", -1 do
      delete "/expo_push_tokens", params: { user_id: @jsmith.id }
    end
    assert_redirected_to "/users/#{@jsmith.id}/edit"

    assert_raise ActiveRecord::RecordNotFound do
      @t2.reload
    end
    @t1.reload
  end


  test 'admin should be able to create token with optional user id' do
    assert_difference "ExpoPushToken.count" do
      post "/expo_push_tokens.json",
        params: @user_id_payload,
        headers: {"CONTENT_TYPE" => 'application/json'}.merge(@admin_creds)
      assert_response 201
    end
    assert_equal @user.id, ExpoPushToken.last.user_id
  end

  test 'non-admin should not able to create token with optional user id' do
    assert_difference "ExpoPushToken.count" do
      post "/expo_push_tokens.json",
        params: @user_id_payload,
        headers: {"CONTENT_TYPE" => 'application/json'}.merge(@jsmith_creds)
      assert_response 201
    end
    assert_equal @jsmith.id, ExpoPushToken.last.user_id
  end

end
