require 'openssl'

class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]

  # GET /logout
  def logout
    session[:user_id] = nil

    redirect_to :root
  end

  # POST /authenticate
  def authenticate
    # verify random string originated from server
    if session[:random_challenge] == nil
      redirect_to :root
      return
    end

    # 7. Clients sends username and (c,z)
    u = User.find_by_username(params[:username])
    c = params[:c]
    z = params[:z]

    if u == nil or c.to_i.to_s != c or z.to_i.to_s != z
      redirect_to :root
      return
    end

    a = session[:random_challenge].to_i
    c = c.to_i
    z = z.to_i
    y = u.publickey.to_i
    g = 3
    p = 4074071952668972172536891376818756322102936787331872501272280898708762599526673412366794779

    # 8. The server calculates T=Y^c g^z and verifies that c=H(Y,T1,a)
    t = (modexp(y, c, p) * modexp(g, z, p)) % p

    sha256 = Digest::SHA256.new
    sha256.update("" + y.to_s + t.to_s + a.to_s + "")
    digest = sha256.digest.to_i

    if c == digest
      session[:user_id] = u
    end

    session[:random_challenge] = nil
    
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
        format.html { redirect_to :root }
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

    #checks g^u mod p
    def modexp(g, u, p)
      return g.to_bn.mod_exp(u, p)
    end
end
