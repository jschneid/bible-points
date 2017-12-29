ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Returns true if a test user is logged in.
    def user_authenticated?
      !session[:user_id].nil?
    end

    def do_login(email, password)
      post login_path, params: { session: { email: email, password: password } }
      assert user_authenticated?, 'User should be authenticated after a valid POST to the login form'
    end

    def create_registered_user(user_params)
      # Provide a password if one wasn't specified. (We'll use a hard-coded password instead
      # of a random one to avoid introducing any potential flakiness.)
      if user_params[:password].nil? && user_params[:password_confirmation].nil?
        user_params[:password] = 'abcde12345'
        user_params[:password_confirmation] = 'abcde12345'
      end
      user = User.new(user_params)
      user.save!
      user
    end

    def create_and_login_user(user_params)
      create_registered_user user_params
      do_login user_params[:email], user_params[:password]
    end

    def create_image(**image_params)
      # Provide a tag if one wasn't specified.
      image_params[:tag_list] = 'my_tag' if image_params[:tag_list].nil?

      Image.new(image_params)
    end

    def create_and_save_image(image_params)
      image = create_image image_params
      image.save!
      image
    end
  end
end
