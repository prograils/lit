namespace :lit do
  desc 'Exports translated strings from lit to config/locales/lit.yml file.'
  task export: :environment do
    locale_keys = ENV['LOCALES'].to_s.split(',') || []
    export_format = ENV['FORMAT'].presence&.downcase&.to_sym || :yaml

    if yml = Lit::Export.call(locale_keys: locale_keys, format: export_format)
      path = Rails.root.join('config', 'locales', "lit.#{file_extension(export_format)}")
      File.new(path, 'w').write(yml)
      puts "Successfully exported #{path}."
    end
  end

  desc 'Exports translated strings from lit to config/locales/%{locale}.yml file.'
  task export_splitted: :environment do
    locale_keys = ENV['LOCALES'].to_s.split(',') || []
    export_format = ENV['FORMAT'].presence&.downcase&.to_sym || :yaml

    hash = YAML.load(Lit::Export.call(locale_keys: locale_keys, format: export_format))
    hash.keys.each do |locale|
      path = Rails.root.join('config', 'locales', format("%s.#{file_extension(export_format)}", locale))
      File.write(path, hash.slice(locale).to_yaml)
      puts format('Successfully exported %s.', path)
    end
  end

  desc 'Reads config/locales/#{ENV["FILES"]} files and calls I18n.t() on keys forcing Lit to import given LOCALE to cache / to display them in UI. Skips nils by default (change by setting ENV["SKIP_NIL"] = false'
  task raw_import: :environment do
    return 'you need to define FILES env' if ENV['FILES'].blank?
    return 'you need to define LOCALE env' if ENV['LOCALE'].blank?
    files = ENV['FILES'].to_s.split(',')
    locale = ENV['LOCALE'].to_s
    skip_nil = ['1', 'true'].include?(ENV['SKIP_NIL'])
    raw = ['0', 'false'].exclude?(ENV['RAW'])
    I18n.with_locale(locale) do
      files.each do |file|
        locale_file = File.open(Rails.root.join('config', 'locales', file))
        Lit::Import.call(
          input: locale_file,
          locale_keys: [locale],
          format: :yaml,
          skip_nil: skip_nil,
          raw: raw
        )
      end
    end
  end

  desc 'Remove all translations'
  task clear: :environment do
    Lit::LocalizationKey.destroy_all
    Lit::IncommingLocalization.destroy_all
    Lit.init.cache.reset
  end

  def file_extension(format)
    case format.to_sym
    when :yaml then 'yml'
    when :csv then 'csv'
    else raise ArgumentError
    end
  end
end
