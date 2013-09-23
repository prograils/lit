
# Which authentication function to use (ie. :authenticate_user!)? When set to
# `nil` will let everyone in.
Lit.authentication_function = <%= @authentication_function || 'nil' %>

# Either 'redis' or 'hash'. Hash is the fastest, but will fail in multiprocess
# environment
Lit.key_value_engine = "<%= @key_value_engine %>"

# Pass extra options to key_value_neinge, ie. prefix for redis (only one
# supported at the moment)
# Lit.storage_options = { :prefix=>"my_project" }

# Translations without default will be humanized (default string will be added)
# ie. scope.page_header will become "Page header"
# If `false` then will serve nil instead (but translation will be wrapped in
# <span title="translation missing string"></span>
Lit.humanize_key = false

# Decide if missing translations will fallback to first found translated value
# (same key, different language)
Lit.fallback = true

# API enabled? API allows third party browsing your translations, as well as
# synchronizing them between environments
Lit.api_enabled = false

# API key is required to authorize third party, if API is enabled
Lit.api_key = "<%= @api_key %>"

# Initialize lit
Lit.init


