require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create_registered_user(name: 'Jon Example', email: 'jon@example.com', password: 'abc123', password_confirmation: 'abc123')
    @user2 = create_registered_user(name: 'Melissa Example', email: 'melissa@example.com', password: 'abc123', password_confirmation: 'abc123')
  end

  def test_new__login_page_load_success
    get login_path
    assert_response :ok
  end

  def test_create__valid_login
    post login_path, params: { session: { email: @user.email, password: @user.password } }
    assert_redirected_to root_path
    assert user_authenticated?, 'User should be logged in after a valid login form POST'
    assert_equal "Hi, #{@user[:name]}! Welcome back!", flash[:success]
    assert_predicate flash[:danger], :nil?
  end

  def test_create__valid_login_with_remember_me
    post login_path, params: { session: { email: @user.email, password: @user.password, remember_me: '1' } }
    assert_redirected_to root_path
    assert user_authenticated?, 'User should be logged in after post to login_path with valid credentials'
    assert_not_nil cookies['remember_token'], "Cookie with remember_token key should not be nil. Debug: Cookies=#{cookies.inspect}"
  end

  def test_create__valid_login_without_remember_me
    post login_path, params: { session: { email: @user.email, password: @user.password, remember_me: '0' } }
    assert_redirected_to root_path
    assert user_authenticated?, 'User should be logged in after post to login_path with valid credentials, regardless of remember_me being unchecked'
    assert_nil cookies['remember_token']
  end

  def test_create__invalid_login_nonexistent_user
    post login_path, params: { session: { email: 'did_not_register_here@example.com', password: 'abc123' } }
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
    assert_not user_authenticated?, 'User should NOT be logged in after post to login_path with invalid credentials'
    assert_predicate flash[:success], :nil?
    assert_equal 'Invalid email/password combination', flash[:danger]
  end

  def test_create__invalid_login_wrong_password
    post login_path, params: { session: { email: @user.email, password: 'not_the_right_password' } }
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
    assert_not user_authenticated?, 'User should NOT be logged in after post to login_path with invalid credentials'
    assert_predicate flash[:success], :nil?
    assert_equal 'Invalid email/password combination', flash[:danger]
  end

  def test_create__invalid_login_blank_password
    post login_path, params: { session: { email: @user.email, password: '' } }
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
    assert_not user_authenticated?, 'User should NOT be logged in after post to login_path with invalid credentials'
    assert_predicate flash[:success], :nil?
    assert_equal 'Invalid email/password combination', flash[:danger]
  end

  def test_new__already_logged_in
    do_login(@user.email, @user.password)
    get login_path
    assert_redirected_to root_path
  end

  # If an authenticated user (somehow) submits another login request, and the credentials for that
  # new request are valid, then verify that we just go ahead and log in that new user.
  def test_create__already_logged_in__valid_login
    do_login(@user.email, @user.password)
    get root_path # This is needed to clear the flash[:success] from the above successful login
    post login_path, params: { session: { email: @user2.email, password: @user2.password } }
    assert_redirected_to root_path
    assert user_authenticated?, 'User should be logged in after the login form POST'
    assert_equal "Hi, #{@user2[:name]}! Welcome back!", flash[:success]
    assert_predicate flash[:danger], :nil?
  end

  # If an authenticated user (somehow) submits another login request, and the credentials for that
  # new request are invalid, then verify that we log out the authenticated user and act as though
  # an anonymous user had failed to log in.
  def test_create__already_logged_in__invalid_login
    do_login(@user.email, @user.password)
    get root_path # This is needed to clear the flash[:success] from the above successful login
    post login_path, params: { session: { email: @user.email, password: 'not_the_right_password' } }
    assert_select 'h1', 'Log in'
    assert_not user_authenticated?, 'User should not be logged in after an invalid login form POST'
    assert_predicate flash.now[:success], :nil?
    assert_equal 'Invalid email/password combination', flash[:danger]
  end

  def test_destroy__success
    delete logout_path
    assert_not user_authenticated?, 'User should not be authenticated after logging out'
    assert_redirected_to root_url
    assert_predicate flash, :empty?
  end
end
