require 'securerandom'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

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

  # POST /challenge
  def challenge
    # generate and encode random string
    @user = User.find_by_username(params[:username])
    r = SecureRandom.base64(1024)
    sessions[:attempted_user_id] = @user.id
    sessions[:random_challenge] = r
    # r = encode(r, @user.publickey)

    @r = r

    respond_to do |format|
      format.js
    end    
  end

  # POST /authenticate
  def authenticate
    # verify random strings are correct
    @user = User.find(params[user_id])
    r = params[random_challenge]
    
    if r.equals?(session[:random_challenge]) and @user.id.equals?(session[:attempted_user_id])
      session[:user_id] = @user.id
    end
    
    redirect_to :root 
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
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
