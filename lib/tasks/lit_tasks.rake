# desc "Explaining what the task does"
# task :lit do
#   # Task goes here
# end
namespace :lit do
  task :export => :environment do
    Lit.init.cache.load_all_translations
    if yml = Lit.init.cache.export
      PATH = "config/locales/lit.yml"
      File.new("#{Rails.root}/#{PATH}", 'w').write(yml)
      puts "Successfully exported #{PATH}."
    end
  end
end
