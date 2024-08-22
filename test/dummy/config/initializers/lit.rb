Lit.authentication_function = :authenticate_admin!
Lit.authentication_verification = :admin_signed_in?
Lit.key_value_engine = ENV["LIT_STORAGE"] || "redis"
Lit.store_humanized_key = false
Lit.ignore_yaml_on_startup = false
Lit.api_enabled = true
Lit.api_key = "ala"
Lit.all_translations_are_html_safe = true
Rails.application.config.after_initialize do
  Lit.init
end
