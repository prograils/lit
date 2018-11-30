namespace :lit do
  desc 'Exports translated strings from lit to config/locales/lit.yml file.'
  task export: :environment do
    locale_keys = ENV['LOCALES'].to_s.split(',') || []
    export_format = ENV['FORMAT'].presence&.downcase&.to_sym || :yaml
    include_hits_count = ENV['INCLUDE_HITS_COUNT'].present?
    path = ENV['OUTPUT'].presence || Rails.root.join('config', 'locales', "lit.#{file_extension(export_format)}")
    if exported = Lit::Export.call(locale_keys: locale_keys, format: export_format,
                                   include_hits_count: include_hits_count)
      File.new(path, 'w').write(exported)
      puts "Successfully exported #{path}."
    end
  end

  desc 'Exports translated strings from lit to config/locales/%{locale}.yml file.'
  task export_splitted: :environment do
    locale_keys = ENV['LOCALES'].to_s.split(',').presence || I18n.available_locales
    export_format = ENV['FORMAT'].presence&.downcase&.to_sym || :yaml

    locale_keys.each do |loc|
      path = Rails.root.join('config', 'locales',
                             "#{loc}.#{file_extension(export_format)}")
      if exported = Lit::Export.call(locale_keys: locale_keys, format: export_format)
        File.write(path, exported)
        puts "Successfully exported #{path}."
      end
    end
  end

  desc "Imports locales given in ENV['LOCALES'] (optional, imports all " \
       "locales by default, from file given in ENV['FILE']; FILE may be " \
       "a YAML or CSV (comma- or tab-separated) file."
  task import: :environment do
    locale_keys = ENV.fetch('LOCALES', '').split(',')
    raise 'you need to define FILE env' unless filename = ENV.fetch('FILE', nil)
    format =
      case filename
      when /\.csv\z/, /\.tsv\z/ then :csv
      when /\.yml\z/, /\.yaml\z/ then :yaml
      else raise 'file must be a CSV or YAML file'
      end
    input = File.open(filename)
    skip_nil = ['1', 'true'].include?(ENV['SKIP_NIL']) # defaults to false
    Lit::Import.call(
      input: input,
      locale_keys: locale_keys,
      format: format,
      skip_nil: skip_nil,
      raw: false
    )
  end

  warm_up_keys_desc =
    'Reads config/locales/#{ENV["FILES"]} files and calls I18n.t() on ' \
    'keys forcing Lit to import given LOCALE to cache / to display them' \
    ' in UI. Skips nils by default (change by setting ENV["SKIP_NIL"] = false'
  desc warm_up_keys_desc
  task warm_up_keys: :environment do
    raise 'you need to define FILES env' if ENV['FILES'].blank?
    raise 'you need to define LOCALE env' if ENV['LOCALE'].blank?
    files = ENV['FILES'].to_s.split(',')
    locale = ENV['LOCALE'].to_s
    skip_nil = ['1', 'true'].include?(ENV['SKIP_NIL'])
    I18n.with_locale(locale) do
      files.each do |file|
        locale_file = File.open(Rails.root.join('config', 'locales', file))
        Lit::Import.call(
          input: locale_file,
          locale_keys: [locale],
          format: :yaml,
          skip_nil: skip_nil,
          raw: true
        )
      end
    end
  end

  desc "[DEPRECATED - use lit:warm_up_keys instead] #{warm_up_keys_desc}"
  task raw_import: :warm_up_keys

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
