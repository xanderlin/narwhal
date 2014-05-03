require 'securerandom'

class HomeController < ApplicationController
  def index
  	@user = User.new
  	
  	@challenge = SecureRandom.base64(100)
  	session[:random_challenge] = @challenge
  end
end
