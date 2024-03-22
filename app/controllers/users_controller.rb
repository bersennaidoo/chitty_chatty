class UsersController < ApplicationController

  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  # /users
  def index
    @users = User.paginate(page: params[:page])
  end

  # /users/:id
  def show
    @user = User.find(params[:id])
  end

  # /users/new
  def new
    @user = User.new
  end

  # /users
  def create 
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
      flash[:success] = "Welcome to the Chitty Chatty App!"
      redirect_to @user
    else
      render "new", status: :unprocessable_entity
    end
  end

  # /users/:id/edit
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to user_path(@user)
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end
  
  private def user_params
    params.require(:user).permit(:name, :email, 
                                 :password, :password_confirmation)
  end

  private def logged_in_user
    if !logged_in? 
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url, status: :see_other
    end
  end

  private def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  private def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end
end
