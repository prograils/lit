# Lost in translation
### Rails i18n web interface

Translate your apps with pleasure (sort of...) and for free. It's simple i18n
web interface,that one may find helpful in
translating app by non-technicals.

Highly inspired by Copycopter by thoughtbot.

[![travis status](https://travis-ci.org/prograils/lit.svg)](https://travis-ci.org/prograils/lit)

### Features

1. Runs with your app - no need for external services
2. Support for array types, (ie. `date.abbr_day_names`)
3. Versioning translations - you can always check, how value did look like in past
4. Possibility to synchronize translations between environments or apps
5. Easy to install - works as an engine, comes with simple generator
6. You can always export all translations to plain old YAML file which can then be imported elsewhere. Translations can also be exported to (and then imported from) a CSV file so that e.g. a third party can easily edit translations for you using any spreadsheet editor, without access to your website's Lit panel.
7. Has build in wysiwyg editor ([jQuery TE](http://jqueryte.com/))
8. Translating apps directly in frontend (see bellow)
9. (On request) stores paths where translation keys were called
10. (On request) is able to show all translation keys used to render current page


### Screenshots

[Feature overview on YouTube](https://www.youtube.com/watch?v=_T9Kg05VvLI)

![lit live translation](https://prograils-com-stuff.s3.amazonaws.com/lit/lit-front.gif)

Check wiki for more: [Screenshots](https://github.com/prograils/lit/wiki/Screenshots)

### Installation

1. Add `lit` gem to your `Gemfile`
```ruby
gem 'lit'
```

  For Ruby < 1.9 use `gem 'lit', '= 0.2.4'`, as next versions introduced new ruby hash syntax.

  For Ruby < 3.x use `gem 'lit', '< 2.0'`

  Starting with version 2.x support for Rails < 7.0 and Ruby < 3.2.5 has been dropped. 

2. run `bundle install`

3. Add `config.i18n.available_locales = [...]` to `application.rb` - it's required to precompile appropriate language flags in lit backend.

4. run installation generator `bundle exec rails g lit:install`
  (for production/staging environment `redis` is suggested as key value engine. `hash` will not work in multi process environment)

5. After doing above and restarting app, point your browser to `http://app/lit`

6. Profit!


You may want to take a look at generated initializer in `config/initializers/lit.rb` and change some default configuration options.

Note `Lit.ignore_yaml_on_startup = true` setting - when it's set to true, Lit won't automatically import translations from yaml and add them to interface. Either change this to `false` or import using rake task

### So... again - what is it and how to use it?
*Lit* is Rails engine - it runs in it's own namespace, by default it's available under `/lit`. It provides UI for managing translations of your app.

Once you call `I18n.t()` function from your views, *Lit* is asked whether it has or not proper value for it. If translation is present in database and is available for *Lit*, it's served back. If it does not exist, record is automatically created in database with initial value provided in `default` option key. If `default` key is not present, value `nil` is saved to database. When app is starting, *Lit* will preload all keys from your local `config/locale/*.yml` files - this is why app startup may take a while.

To optimize translation key lookup, *Lit* can use different cache engines. For production with many workers `redis` is suggested, for local development `hash` will be fine (`hash` is stored in memory, so if you have many workers and will update translation value in backend, only one worker will have proper translation in it's cache - db will be updated anyway).

Keys ending with `_html` have auto wysiwyg support.

### Import and export

#### Export

Translations can be exported using the `lit:export` rake task:
```bash
$ rake lit:export
```

The task exports to YAML format by default, which can be overridden by setting the `FORMAT` environment variable to `csv`.
As well as this, by default, it exports all of your application's locales; using the `LOCALES` environment variable you can limit it to specific locales.
Using `OUTPUT` environment variable you can specify the output file (defaults to `config/locales/lit.yml` or `.csv`).

 For example:
```bash
$ rake lit:export FORMAT=csv LOCALES=en,pl OUTPUT=export.csv
```
...will only export the `en` and `pl` locales, producing CSV output to `export.csv` in the current folder.

Using the task `lit:export_splitted` does the same as `lit:export` but splits the locales by their name (`config/locales/en.yml`, etc).

Optionally, the `INCLUDE_HITS_COUNT` option (only applicable for CSV export) can be used to include current hits count for each localization key. Note that it only makes sense to use this option when Redis is Lit's key-value engine because these counters are stored in cache and not in the database.

#### Import

Translation import is handled using the `lit:import` task, where imported file name should be specified in the `FILE` envionment variable:
```bash
$ rake lit:import FILE=stuff.csv
```

Optionally, `LOCALES` and `SKIP_NIL` environment variables can be used to select specific locales to import from a multi-locale CSV file and to prevent nil values from being set as translated values for localizations, respectively.
The following call:
```bash
$ rake lit:import FILE=stuff.csv LOCALES=en,pl SKIP_NIL=1
```
...will only load `en` and `pl` locales from the file, skipping nil values.

Additionally, there is the `lit:warm_up_keys` task (temporarily aliased as `lit:raw_import` for compatibility) which serves a different purpose: rather than for actual import of translations, it is intended to pre-load into database translations from a specific locale's YAML file **when the application is first deployed to a server and not all translation keys are present in the database yet**. This task also takes the `SKIP_NIL` option in a similar way as the import task.
```bash
$ rake lit:warm_up_keys FILES=config/locales/en.yml LOCALES=en
```
In this case, when the `config/locales/en.yml` contains a translation for `foo` which doesn't have a key in the DB yet, it will be created, but if it already exists in the DB with a translation, it won't be overridden.

#### Deleted keys

Keys marked as deleted (i.e. still existing but deleted from the Lit UI) are *not* exported. In order to make these keys exported again, you need to restore them from the "Deleted and visited again" view.

Deleted keys whose translations are encountered during import are restored automatically.

### Cloud translation services

Lit can use external translation services such as [Google Cloud Translation API](https://cloud.google.com/translate/) and [Yandex.Translate API](https://translate.yandex.com/developers) to tentatively translate localizations to a given language.
Currently, Google and Yandex translation providers are supported, but extending it to any other translation provider of your choice is as easy as subclassing `Lit::CloudTranslation::Providers::Base`; see classes in `lib/lit/cloud_translation/providers` for reference.

#### Usage

Configure your translation provider using one of routines described below. When a translation provider is configured, each localization in Lit web UI will have a "Translate using _Provider Name_" button next to it, which by default translates to the localization's language from the localization currently saved for the app's `I18n.default_locale`.
Next to the button, there is a dropdown that allows translating from the key's localization in a language different than the default one.

#### Google Cloud Translation API

Insert this into your Lit initializer:
```
require 'lit/cloud_translation/providers/google'

Lit::CloudTranslation.provider = Lit::CloudTranslation::Providers::Google
```

...and make sure you have this in your Gemfile:
```
gem 'google-cloud-translate', '~> 2.1.2'
```

To use translation via Google, you need to obtain a [service account key](https://cloud.google.com/iam/docs/creating-managing-service-account-keys) containing all the credentials required by the API.

These credentials can be given in three ways:
* via a `.json` keyfile, the path to which should be stored in the `GOOGLE_TRANSLATE_API_KEYFILE` environment variable,
* programmatically, in the initializer - be sure to use secrets in all the sensitive fields so you don't expose private credentials in the code:
  ```
  Lit::CloudTranslation.configure do |config|
    config.keyfile_hash = {
      'type' => 'service_account',
      'project_id' => 'foo',
      'private_key_id' => 'keyid',
      ... # see Google docs link above for reference
    }
  end

  # For example, for Rails 6, from encrypted credentials file (HashWithIndifferentAccess is used, because the keys in
   the credentials.config could be strings or, as well, symbols):

  Lit::CloudTranslation.configure do |config|
    config.keyfile_hash = HashWithIndifferentAccess.new(Rails.application.credentials.config[:google_translate_api])
  end
  ```
* directly via `GOOGLE_TRANSLATE_API_<element>` environment variables, where e.g. the `GOOGLE_TRANSLATE_API_PROJECT_ID` variable corresponds to the `project_id` element of a JSON keyfile. Typically, only the following variables are mandatory:
  * `GOOGLE_TRANSLATE_API_PROJECT_ID`
  * `GOOGLE_TRANSLATE_API_PRIVATE_KEY` (make sure that it contains correct line breaks and markers of the private key's begin and end)
  * `GOOGLE_TRANSLATE_API_CLIENT_EMAIL`

#### Yandex.Translate API

Insert this into your Lit initializer:
```
require 'lit/cloud_translation/providers/yandex'

Lit::CloudTranslation.provider = Lit::CloudTranslation::Providers::Yandex
```

To use Yandex translation, an [API key must be obtained](https://translate.yandex.com/developers/keys). Then, you can pass it to your application via the `YANDEX_TRANSLATE_API_KEY` environment variable.

The API key can also be set programmatically in your Lit initializer (again, be sure to use secrets if you choose to do so):
```
Lit::CloudTranslation.configure do |config|
  config.api_key = 'the_api_key'
end
```

### 1.x -> 2.0.x upgrade guide

Also applies to upgrading from `1.x` versions.

1. Specify `gem 'lit', '~> 2.0.0'` in your Gemfile and run `bundle update lit`.

### 0.3 -> 1.0 upgrade guide

Also applies to upgrading from `0.4.pre.alpha` versions.

1. Specify `gem 'lit', '~> 1.0'` in your Gemfile and run `bundle update lit`.
2. Run Lit migrations - `rails db:migrate`.
   * __Caution:__ One of the new migrations adds a unique index in `lit_localizations` on `(localization_key_id, locale_id)`, which may cause constraint violations in some cases. If you encounter such errors during running this migration - in this case you'll need to enter Rails console and remove duplicates manually. The following query might be helpful to determine duplicate locale/localization key ID pairs:
   ```
   Lit::Localization.group(:locale_id, :localization_key_id).having('count(*) > 1').count
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

1. Include `Lit::RequestInfoStore` concern in your `ApplicationController`

```ruby
include Lit::RequestInfoStore
```

2. In lit initializer (`lit.rb`) set `store_request_info` config to true

```ruby
Lit.store_request_info = true
```

3. Lit authorized user must be signed in for this feature to work!

### Showing called translations in frontend


1. Add `Lit::FrontendHelper` in your `ApplicationController`

```ruby
helper Lit::FrontendHelper
```

2. Include `Lit::RequestKeysStore` concern in your `ApplicationController`

```ruby
include Lit::RequestKeysStore
```

3. Enable storing of request keys in lit initializer `config/initializers/lit.rb`

```ruby
Lit.store_request_keys = true
```

4. On the bottom of you layout file call `lit_translations_info` helper function

```erb
<%= lit_translations_info %>
```

5. From now on you'll be able to see all translation keys that were used to render current page. This feature works great with on-site live translations!

6. Lit authorized user must be signed in for this feature to work! This feature requires jQuery!



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

1. `gem install bundler && bundle install` - ensure Bundler and all required gems are installed
2. `bundle exec appraisal install` - install gems from appraisal's gemfiles
3. `cp test/dummy/config/database.yml.sample test/dummy/config/database.yml` - move a database.yml in place (remember to fill your DB credentials in it)
4. `RAILS_ENV=test bundle exec appraisal rails-5.2 rake db:setup` - setup lit DB (see test/config/database.yml); do it
 only once, it does not matter which Rails version you use for `appraisal`
5. `bundle exec appraisal rake` - run the tests!

### License

Lit is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.

