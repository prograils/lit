if ::Rails::VERSION::MAJOR == 3 ||
    (::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR == 0)
  require 'i18n'

  # Override exception handler to more carefully html-escape missing-key results.
  class HtmlSafeI18nExceptionHandler
    def call(exception, locale, key, options)
      keys = exception.keys.map { |k| Rack::Utils.escape_html k }
      key = keys.last.to_s.gsub('_', ' ').gsub(/\b('?[a-z])/) { $1.capitalize }
      %(<span class="translation_missing" title="translation missing: #{keys.join('.')}">#{key}</span>)
    end
  end

  I18n.exception_handler = HtmlSafeI18nExceptionHandler.new
end
