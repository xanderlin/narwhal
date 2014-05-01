class User < ActiveRecord::Base
  validates_uniqueness_of :username
end
