class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Post created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
      # Maybe use:
      # flash[:danger] = "Post cannot be blank."
      # redirect_to root_url
    end
  end
  
  def destroy
    @micropost.destroy
    flash[:success] = "Post deleted"
    redirect_to request.referer || root_url
  end
  
  private
  
    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end
    
    # Confirms the correct user, allows admin (strictly for destroy)
    def correct_user
      @micropost = current_user.admin? ? Micropost.find_by(id: params[:id]) : current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
  
end
