require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    user_params = { name: 'Jon S.', email: 'jon@example.com', password: 'abc123', password_confirmation: 'abc123' }
    @user = User.new(user_params)
    remember(@user)
  end

  # Verify that current_user (1) returns us the user saved in a valid authentication cookie,
  # and (2) logs that user in, when there is no currently logged in user.
  def test_current_user__session_nil
    assert_equal @user, current_user
    assert user_authenticated?, 'User should be logged in when there is a valid, current login cookie'
  end

  def test_current_user__incorrect_remember_digest
    @user.update_attributes(remember_digest: User.digest(User.new_token))
    assert_nil current_user, 'User should not be logged in when the login cookie token isn\'t valid'
  end
end
