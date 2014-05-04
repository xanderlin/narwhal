require 'securerandom'

class HomeController < ApplicationController
  def index
  	@user = User.new

  	@challenge = 2514315923
  	session[:random_challenge] = @challenge
  end
end
