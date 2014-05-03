require 'securerandom'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def logout
    session[:user_id] = nil

    redirect_to :root
  end

  # POST /challenge
  def challenge
    # generate and encode random string
    user = User.find_by_username(params[:username])
    @r = SecureRandom.base64(100)
    # @r = encode(@r, @user.publickey)

    session[:attempted_user_id] = user.id
    session[:random_challenge] = @r

    respond_to :js
  end

  # POST /authenticate
  def authenticate
    # verify random strings are correct
    user = User.find_by_username(params[:username])
    r = params[:random_challenge]
    
    if r == (session[:random_challenge]) and user.id == (session[:attempted_user_id])
      session[:user_id] = user.id
    end
    
    redirect_to :root 
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        session[:user_id] = @user
        format.html { redirect_to :root, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :publickey)
    end
end
