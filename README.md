# Lost in translation
### Rails i18n web interface

Translate your apps with pleasure (sort of...) and for free. It's simple i18n
web interface, build on top of twitter bootstrap, that one may find helpful in
translating app by non-technicals.

Highly inspired by Copycopter by thoughtbot.

![travis status](https://travis-ci.org/prograils/lit.svg)

### Features

1. Runs with your app - no need for external services
2. Support for array types, (ie. `date.abbr_day_names`)
3. Versioning translations - you can always check, how value did look like in past
4. Possibility to synchronize translations between environments or apps
5. Easy to install - works as an engine, comes with simple generator
6. You can always export all translations to plain old YAML file
7. Has build in wysiwyg editor ([jQuery TE](http://jqueryte.com/))
8. Translating apps directly in frontend (see bellow)
9. (On request) stores paths where translation keys were called
10. (On request) is able to show all translation keys used to render current page

### Screenshots

Check wiki: [Screenshots](https://github.com/prograils/lit/wiki/Screenshots)

### Installation

1. Add `lit` gem to your `Gemfile`
```ruby
gem 'lit'
```

  For Ruby < 1.9 use `gem 'lit', '= 0.2.4'`, as next versions introduced new ruby hash syntax.

2. run `bundle install`

3. run installation generator `bundle exec rails g lit:install`
  (for production/staging environment `redis` is suggested as key value engine. `hash` will not work in multi process environment)
  
4. Add `config.i18n.available_locales = [...]` to `application.rb` - it's required to precompile appropriate language flags in lit backend.

5. After doing above and restarting app, point your browser to `http://app/lit`

6. Profit!


You may want to take a look at generated initializer in `config/initializers/lit.rb` and change some default configuration options.

### So... again - what is it and how to use it?
*Lit* is Rails engine - it runs in it's own namespace, by default it's avaulable under `/lit`. It provides UI for managing translations of your app.

Once you call `I18n.t()` function from your views, *Lit* is asked whether it has or not proper value for it. If translation is present in database and is available for *Lit*, it's served back. If it does not exists, record is automatically created in database with initial value provided in `default` option key. If `default` key is not present, value `nil` is saved to database. When app is starting, *Lit* will preload all keys from your local `config/locale/*.yml` files - this is why app startup may take a while.

To optimize translation key lookup, *Lit* can use different cache engines. For production with many workers `redis` is suggested, for local development `hash` will be fine (`hash` is stored in memory, so if you have many workers and will update translation value in backend, only one worker will have proper translation in it's cache - db will be updated anyway).

Keys ending with `_html` have auto wysiwyg support.

You can also export translations using rake task

```bash
$ rake lit:export
```

You may also give it extra env variables to limit the export results.

```bash
$ LOCALES=en,de rake lit:export
```


### 0.2 -> 0.3 upgrade guide

1. Specify exact lit version in your Gemfile: `gem 'lit', '~> 0.3.0'`
2. Run `bundle update lit`
3. Add `config.i18n.available_locales` to your `application.rb` (see 3rd point from Installation info)
4. Add `config.i18n.enforce_available_locales = true` config to your `application.rb`
5. Compare your current `lit.rb` initializer with [template](https://github.com/prograils/lit/blob/master/lib/generators/lit/install/templates/initializer.rb).

### On-site live translations

1. Add `Lit::FrontendHelper` to your `ApplicationController`

	```ruby
	helper Lit::FrontendHelper
	```

2. In you layout file include lit assets

	```erb
	<% if admin_user_signed_in? %>
	  <%= lit_frontend_assets %>
	<% end %>
	```

3. You're good to go - now log in to lit (if required) and open your frontend in separate tab (to have session persisted). On the bottom-right of your page you should see "Enable / disable lit highlight" - after enabling it you'll be able to click and translate phrases directly in your frontend

4. Once enabled, all translations called via `t` helper function be rendered inside `<span />` tag, what may break your layout (ie if you're using translated values as button values or as placeholders, etc). To avoid that add `skip_lit: true` to `t()` call or use `I18n.t`.

5. This feature requires jQuery! (at least for now)

### Storing request info

1. Include `Lit::Concerns::RequestInfoStore` concern in your `ApplicationController`

	```ruby
	include Lit::Concerns::RequestInfoStore
	```

2. In lit initializer (`lit.rb`) set `store_request_info` config to true

```ruby
Lit.store_request_info = true
```

3. Lit authorized user must be signed in for this feature to work!

### Showing called translations in frontend


1. Add `Lit::FrontendHelper` in your `ApplicationController`

	```ruby
	include Lit::FrontendHelper
	```

2. Include `Lit::Concerns::RequestKeysStore` concern in your `ApplicationController`

	```ruby
	include Lit::Concerns::RequestKeysStore
	```

3. On the bottom of you layout file call `lit_translations_info` helper function

	```erb
	<%= lit_translations_info %>
	```

4. From now on you'll be able to see all translation keys that were used to render current page. This feature works great with on-site live translations!

5. Lit authorized user must be signed in for this feature to work! This feature requires jQuery!



### ToDo

* ~~Versioning~~
* ~~API~~
* ~~Synchronization between environments~~
* Rewrite initializer
* ~~Rewrite exporter (which is now code from copycopter)~~
* ~~Support for array types (ie. `date.abbr_day_names`)~~
* ~~Generator~~
* ~~Support for wysiwyg~~
* ~~Better cache~~
* ~~Support for other key value providers (ie. Redis does not support Array types in easy way)~~ (not applicable, as array storage works now with redis).
* Integration with ActiveAdmin
* Support for Proc defaults (like in `I18n.t('not_exising_keys', default: lambda{|_, options| 'text'})` )

### Testing

For local testing [Appraisal](https://github.com/thoughtbot/appraisal) gem comes into play, run tests via: `bundle exec appraisal rails-4.2 rake test`.

Please remember to edit `test/dummy/config/database.yml` file

### License

Lit is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
