require 'securerandom'

class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]

  # GET /logout
  def logout
    session[:user_id] = nil

    redirect_to :root
  end

  # POST /challenge
  def challenge
    # generate and encode random string
    user = User.find_by_username(params[:username])

    r = SecureRandom.base64(100)

    if not user.nil?
      session[:attempted_user_id] = user.id
      session[:random_challenge] = r
    else
      session[:attempted_user_id] = nil
      session[:random_challenge] = nil
    end

    @r = r
    # @r = encode(r, @user.publickey)

    respond_to :js
  end

  # POST /authenticate
  def authenticate
    # verify server ready to authenticate
    scheck = session[:attempted_user_id] != nil and session[:random_challenge] != nil

    # verify random string matches
    u = User.find_by_username(params[:username])
    ucheck = u != nil and u == session[:attempted_user_id]

    r = params[:random_challenge]
    rcheck = r == session[:random_challenge]

    if scheck and ucheck and rcheck
      session[:user_id] = u
    else
      session[:attempted_user_id] = nil
      session[:random_challenge] = nil
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
