module Lit
  class Railtie < ::Rails::Railtie
    ## INITIALIZE IN config/initialize if you want to use redis!!!
    initializer :initialize_lit_rails, :after => :before_initialize do
      #Lit::Rails.initialize
    end

    #rake_tasks do
      #load "tasks/lit_tasks.rake"
    #end
  end
end
