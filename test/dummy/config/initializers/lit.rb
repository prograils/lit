Lit.authentication_function = :authenticate_admin!
Lit.authentication_verification = :admin_signed_in?
Lit.key_value_engine = ENV['LIT_STORAGE'] || 'redis'
Lit.humanize_key = true
Lit.ignore_yaml_on_startup = true
Lit.api_enabled = true
Lit.api_key = 'ala'
Lit.all_translations_are_html_safe = true
Lit.init
