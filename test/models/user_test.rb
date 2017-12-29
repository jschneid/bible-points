require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    # Set up a valid User object that validates ok. Individual tests can override
    # attributes of this as necessary to test error scenarios.
    @user_params = { name: 'Jon S.', email: 'jon2@example.com', password: 'abc123', password_confirmation: 'abc123', remember_digest: nil }
    @user = User.new(@user_params)
  end

  def test_user_new
    assert_predicate @user, :valid?
  end

  def test_email_coerced_to_lowercase
    @user[:email] = 'JON2@Example.com'
    @user.save!
    assert_equal 'jon2@example.com', @user.email
  end

  def test_user_name_required
    @user[:name] = ''
    assert_predicate @user, :invalid?
    assert_equal({ name: ["can't be blank"] }, @user.errors.messages)
  end

  def test_user_email_required
    @user[:email] = ''
    assert_predicate @user, :invalid?
    assert_equal({ email: ['is invalid'] }, @user.errors.messages)
  end

  def test_user_name_max_length
    long_username = 'a' * 50
    @user[:name] = long_username
    assert_predicate @user, :valid?
  end

  def test_user_name_max_length_plus_one
    too_long_username = 'a' * 51
    @user[:name] = too_long_username
    assert_predicate @user, :invalid?
    assert_equal({ name: ['is too long (maximum is 50 characters)'] }, @user.errors.messages)
  end

  def test_user_email_max_length
    long_email = 'someone@' + 'a' * 243 + '.com' # 255 total chars in length
    @user[:email] = long_email
    assert_predicate @user, :valid?
  end

  def test_user_email_max_length_plus_one
    too_long_email = 'someone@' + 'a' * 244 + '.com' # 256 total chars in length
    @user[:email] = too_long_email
    assert_predicate @user, :invalid?
    assert_equal({ email: ['is too long (maximum is 255 characters)'] }, @user.errors.messages)
  end

  def test_user_password_min_length
    short_password = '123456'
    @user_params[:password] = short_password
    @user_params[:password_confirmation] = short_password
    @user.update_attributes(@user_params)
    assert_predicate @user, :valid?
  end

  def test_user_password_min_length_minus_one
    too_short_password = '12345'
    @user_params[:password] = too_short_password
    @user_params[:password_confirmation] = too_short_password
    @user.update_attributes(@user_params)
    assert_predicate @user, :invalid?
    assert_equal({ password: ['is too short (minimum is 6 characters)'] }, @user.errors.messages)
  end

  def test_user_password_blank
    @user_params[:password] = ''
    # In this case, we need to create a new User instead of just modifying our existing one, since
    # has_secure_password will assume that when we're MODIFYING (not creating) a user and the password
    # field is blank, that we're doing a change of user properties on a My Account page or similar
    # without resetting the user's password at the same time, and will skip password validation.
    @user = User.new(@user_params)
    assert_predicate @user, :invalid?
    assert_equal({ password: ['can\'t be blank'] }, @user.errors.messages)
  end

  def test_email_unique
    @user.save!
    user2 = User.new(name: 'Jonathan Schneider', email: @user[:email], password: 'password2', password_confirmation: 'password2')
    assert_predicate user2, :invalid?
    assert_equal({ email: ['has already been taken'] }, user2.errors.messages)
  end

  def test_email_unique_case_insensitive
    @user[:email] = 'someone@example.com'
    @user.save!
    user2 = User.new(name: 'Some User', email: 'SOMEONE@example.com', password: 'password2', password_confirmation: 'password2')
    assert_predicate user2, :invalid?
    assert_equal({ email: ['has already been taken'] }, user2.errors.messages)
  end

  def test_user_email_well_formed
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user[:email] = valid_address
      assert_predicate @user, :valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # Note: We're using the email_validator gem to enforce well-formed email values, so we're mostly
  # relying on that instead of implementing a comprehensive email validation test suite here. This
  # is just a few examples of not-well-formed emails to verify that the email_validator is wired up.
  def test_user_email_not_well_formed
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user[:email] = invalid_address
      assert_predicate @user, :invalid?, "#{invalid_address.inspect} should be invalid"
      assert_equal({ email: ['is invalid'] }, @user.errors.messages)
    end
  end

  def test_user_password_confirmation_mismatch
    @user_params[:password_confirmation] = 'this does not match'
    @user.update_attributes(@user_params)
    assert_predicate @user, :invalid?
    assert_equal({ password_confirmation: ['doesn\'t match Password'] }, @user.errors.messages)
  end

  def test_user_authenticated_nil_digest
    refute_operator @user, :authenticated?, ''
  end

  def test_user_remember
    assert_predicate @user.remember_token, :blank?
    assert_predicate @user.remember_digest, :blank?
    @user.remember
    assert_predicate @user.remember_token, :present?
    assert_predicate @user.remember_digest, :present?
  end

  # This verifies that if a user logs in with "remember me" in (for example) Firefox,
  # and then does so again in Chrome, the same remember_token will be used in both cases,
  # allowing the user to switch back and forth between browsers without being logged
  # out in one of the browsers due to a mismatch between the browser's cookie and the
  # saved token.
  def test_user_remember_twice_token_does_not_change
    @user.remember
    token1 = @user.remember_token
    @user.remember
    token2 = @user.remember_token
    assert_equal(token1, token2)
  end

  def test_user_authenticated_success
    @user.remember
    assert_operator @user, :authenticated?, @user.remember_token
  end

  def test_user_authenticated_fail_wrong_token
    @user.remember
    refute_operator @user, :authenticated?, 'some invalid token value'
  end

  def test_user_authenticated_fail_blank_token
    @user.remember
    refute_operator @user, :authenticated?, ''
  end

  # Verify that the remember token is cleared following a logout.
  def test_user_forget_clears_remember_token
    @user.remember
    assert_predicate @user.remember_token, :present?
    assert_predicate @user.remember_digest, :present?
    @user.forget
    assert_predicate @user.remember_token, :blank?
    assert_predicate @user.remember_digest, :blank?
  end

  # Verify that the prior remember token is no longer usable following a logout.
  def test_user_forget_remember_token_obsoleted
    @user.remember
    token = @user.remember_token
    assert_operator @user, :authenticated?, token
    @user.forget
    refute_operator @user, :authenticated?, token
  end
end
