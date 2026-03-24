require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:valid_user)
  end

  test "should login with valid credentials" do
    post login_url, params: { email: @user.email, password: "password123" }
    assert_response :success
    token = JSON.parse(response.body)["token"]
    assert_not_nil token
  end

  test "should fail login with invalid credentials" do
    post login_url, params: { email: @user.email, password: "wrongpassword" }
    assert_response :unauthorized
  end

  test "should logout successfully with valid jwt" do
    delete logout_url, headers: auth_headers_for(@user)
    assert_response :success
  end

  test "should fail logout without token" do
    delete logout_url
    assert_response :unauthorized
  end

  test "should actually revoke the token on logout (JTI rotation)" do
    valid_headers = auth_headers_for(@user)

    delete logout_url, headers: valid_headers
    assert_response :success

    delete logout_url, headers: valid_headers

    assert_response :unauthorized
  end
end
