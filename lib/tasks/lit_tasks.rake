namespace :lit do
  desc 'Exports translated strings from lit to config/locales/lit.yml file.'
  task export: :environment do
    if yml = Lit.init.cache.export
      path = Rails.root.join('config', 'locales', 'lit.yml')
      File.new(path, 'w').write(yml)
      puts "Successfully exported #{path}."
    end
  end

  desc 'Reads config/locales/#{ENV["FILES"]} files and calls I18n.t() on keys forcing Lit to import given LOCALE to cache / to display them in UI. Skips nils by default (change by setting ENV["SKIP_NIL"] = false'
  task raw_import: :environment do
    return 'you need to define FILES env' if ENV['FILES'].blank?
    return 'you need to define LOCALE env' if ENV['LOCALE'].blank?
    files = ENV['FILES'].to_s.split(',')
    locale = ENV['LOCALE'].to_s
    I18n.with_locale(locale) do
      files.each do |file|
        locale_file = File.open(Rails.root.join('config', 'locales', file))
        yml = YAML.load(locale_file)[locale]
        Hash[*Lit::Cache.flatten_hash(yml)].each do |key, default_translation|
          next if default_translation.nil? && ENV.fetch('SKIP_NIL', 'true') == 'true'
          puts key
          I18n.t(key, default: default_translation)
        end
      end
    end
  end
end
