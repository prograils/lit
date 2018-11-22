class Project < ActiveRecord::Base
  unless defined?(::ActionController::StrongParameters)
    attr_accessible :name
  end
  validates_presence_of :name

end
