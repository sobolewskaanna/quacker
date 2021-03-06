class TweetsController < ApplicationController

  def index
    @tweets = Tweet.all.order(created_at: :desc)
    respond_to do |format|
      format.json { render :json=> @tweets }
      format.html {
        if current_user
         @following = current_user.following
         @user = current_user
         @tweets = Tweet.all.order(created_at: :desc).paginate(:page => params[:page], per_page: 10)
         render 'users/show'
        else
         @tweets = Tweet.all.order(created_at: :desc).paginate(:page => params[:page], per_page: 10)
         render 'users/show'
        end
      }
    end
  end
  def map
    @tweets = Tweet.all.order(created_at: :desc)
    respond_to do |format|
      format.json { render :json=> @tweets }
      format.html {
        if current_user
         @following = current_user.following
         @user = current_user
         @tweets = Tweet.all.order(created_at: :desc).paginate(:page => params[:page], per_page: 10)
         render :map
        else
         @tweets = Tweet.all.order(created_at: :desc).paginate(:page => params[:page], per_page: 10)
         render :map
        end
      }
    end
  end

  def new
    @tweet = Tweet.new
    render :new
  end

  def create
    @tweet = Tweet.create(tweet_params)
    @user = current_user
    if result = request.location
      if result.longitude && result.latitude
        @tweet.longitude=result.longitude
        @tweet.latitude=result.latitude
      end
    end
    @tweet.save
    @user.tweets << @tweet
    if @tweet.save
      redirect_to user_path(@user)
    else
      redirect_to new_tweet_path
      flash[:notice] = @tweet.errors.full_messages
    end
  end

  def show
    @tweet = Tweet.find(params[:id])
    @comments = @tweet.comments
    @following = current_user.following
    @user = current_user
    render :show
  end

  def update
    @user = current_user
    @tweet = Tweet.find(params[:id])
    if current_user == @tweet.user
      @tweet.update(tweet_params)
    else
      flash[:notice]=@tweet.errors.full_messages
    end
    redirect_to @tweet
  end

  def edit
    @tweet = Tweet.find(params[:id])
    if current_user == @tweet.user
      render :edit
    else
      flash[:notice]=@tweet.errors.full_messages
      redirect_to tweets_path
    end
  end

  def destroy
    @tweet = Tweet.find(params[:id])
    if current_user == @tweet.user
      @tweet.destroy
    else
      flash[:notice]= @tweet.error.full_messages
    end
    redirect_to current_user
  end

  def like
    @tweet = Tweet.find(params[:id])
    @tweet.liked_by current_user
    if request.xhr?
      head :ok
    else
      redirect_to @tweet
    end
  end

  def dislike
    @tweet = Tweet.find(params[:id])
    @tweet.disliked_by current_user
    redirect_to @tweet
  end

  private

  def tweet_params
    params.require(:tweet).permit(:title, :body, :latitude,:longitude, :full_street_address)
  end

end
