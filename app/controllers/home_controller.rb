require 'securerandom'

class HomeController < ApplicationController
  def index
  	@user = User.new

  	@challenge = SecureRandom.random_number(4074071952668972172536891376818756322102936787331872501272280898708762599526673412366794779).to_s;
  	session[:random_challenge] = @challenge
  end
end
