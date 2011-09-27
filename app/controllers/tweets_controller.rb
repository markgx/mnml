class TweetsController < ApplicationController
  def index
    tweets = client.home_timeline(:since_id => params['sinceId']).map { |t|
      { :id => t.id, :text => t.text,
        :full_name => t.user.name,
        :screen_name => t.user.screen_name } }

    render :json => tweets
  end

  def create
    client.update(params['tweet'])
    head :ok
  end
end
