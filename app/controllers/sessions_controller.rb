class SessionsController < ApplicationController
  # For login form submit: If the user (somehow) submits the login form when they are already logged in
  # (perhaps due to multiple browser tabs), then log them out, then process the new login request.
  # For logout: This takes care of ending the user's session.
  before_action :log_out, only: %i[create destroy]

  # Login page load
  def new
    # The user shouldn't be on the sign in page if they're already logged in.
    return redirect_to root_path if logged_in?
  end

  # Login form submit
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in_with_message_and_redirect user
      handle_remember_me_checkbox user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unauthorized
    end
  end

  # Logout
  def destroy
    redirect_to root_url
  end

  private

  def log_in_with_message_and_redirect(user)
    log_in user
    flash[:success] = "Hi, #{user.name}! Welcome back!"
    redirect_to root_path
  end

  def handle_remember_me_checkbox(user)
    if params[:session][:remember_me] == '1'
      remember(user)
    else
      forget(user)
    end
  end
end
