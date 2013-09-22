# Lost in translation
### Rails i18n web interface

Translate your apps with pleasure (sort of...) and for free. It's simple i18n 
web interface, build on top of twitter bootstrap, that one may find helpful in 
translating app by non-technicals. 
It's still under heave development!

Highly inspired by Copycopter by thoughtbot.

### Features

1. Runs with your app - no need for external services
2. Support for array types, (ie. `date.abbr_day_names`)
3. Versioning translations - you can always check, how value did look like in past
4. Easy to install - works as an engine, comes with simple generator
5. You can always export all translations to plain old YAML file

### Screenshots

Check wiki: [Screenshots](https://github.com/prograils/lit/wiki/Screenshots)

### Instalation

1. Add `lit` gem to your `Gemfile`
```ruby
gem "lit"
````

2. run `bundle install`

3. run installation generator `bundle exec rails g lit:install`

4. After doing above and restarting app, point your browser to ```http://app/lit```

5. Profit!


You may want to take a look at generated initializer in `config/initializers/lit.rb` and change some default configuration options.


### ToDo

* ~~Versioning~~ 
* API
* Synchronization between environments
* Rewrite initializer
* Rewrite exporter (which is now code from copycopter)
* ~~Support for array types (ie. `date.abbr_day_names`)~~
* ~~Generator~~
* Support for wysiwyg
* Better cache
* ~~Support for other key value providers (ie. Redis does not support Array types in easy way)~~ (not applicable, as array storage works now with redis).
* Integration with ActiveAdmin


### License

Lit is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
