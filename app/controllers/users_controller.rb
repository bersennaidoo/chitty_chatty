class UsersController < ApplicationController

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
  
  private def user_params
    params.require(:user).permit(:name, :email, 
                                 :password, :password_confirmation)
  end
end
