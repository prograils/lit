namespace :lit do
  desc 'Exports translated strings from lit to config/locales/lit.yml file.'
  task export: :environment do
    if yml = Lit.init.cache.export
      path = Rails.root.join('config', 'locales', 'lit.yml')
      File.new(path, 'w').write(yml)
      puts "Successfully exported #{path}."
    end
  end
end
