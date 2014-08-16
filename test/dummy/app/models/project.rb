class Project < ActiveRecord::Base
  unless defined?(::ActionController::StrongParameters)
    attr_accessible :name
  end
end
