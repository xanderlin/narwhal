require 'securerandom'

class HomeController < ApplicationController
  def index
  	@user = User.new

  	@challenge = SecureRandom.hex(30)
  	session[:random_challenge] = @challenge
  end
end
