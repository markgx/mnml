class SessionsController < ApplicationController
  def create
    session[:access_token] = request.env['omniauth.auth']['credentials']['token']
    session[:access_secret] = request.env['omniauth.auth']['credentials']['secret']
    redirect_to show_path, :notice => "Signed in with Twitter!"
  end

  def show
    if is_logged_in?
      @user = client.user
      @tweets = client.home_timeline.map { |t|
        { :id => t.id, :text => t.text,
          :full_name => t.user.name,
          :screen_name => t.user.screen_name } }
    else
      redirect_to failure_path
    end
  end

  def error
    flash[:error] = "Sign in with Twitter failed!"
    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path, :notice => "Signed out!"
  end
end
