module CopycopterClient
  class Railtie < ::Rails::Railtie
    initializer :initialize_lit_rails, :after => :before_initialize do
      Lit::Rails.initialize
    end

    #rake_tasks do
      #load "tasks/lit_tasks.rake"
    #end
  end
end
