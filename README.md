# Lost in translation
### Rails i18n web interface

Translate your apps with pleasure (sort of...) and for free. It's simple i18n 
web interface, build on top of twitter bootstrap, that one may find helpful in 
translating app by non-technicals. 
It's still under heave development!

Highly inspired by Copycopter by thoughtbot.

### Screenshots

Check wiki: [Screenshots](https://github.com/prograils/lit/wiki/Screenshots)

### Instalation

1. Add ```lit``` gem to your ```Gemfile```
```ruby
gem "lit"
```

2. Install required migrations: ```bundle exec rake lit:install:migrations``` and run migrations ```bundle exec rake db:migrate```

3. Mount engine in ```config/routes.rb```
```ruby
mount Lit::Engine => "/lit"
```

4. Last step is initializer, that should be places ie in ```config/initializers/lit.rb```
    ```ruby
    ## Add extra authentication, symbol, that is provided as param to before_filter
    ## Tested with devise, seems to work
    # Lit.authentication_function = :authenticate_admin!
    
    ## Which storage engine use. Please remember that in production environment
    ## memory is not shared between processes, and hash may not be correct choice
    ## (as changes will not be visible for all processes). But for any production
    ## environment with finished translation, 'hash' is preferred choice.
    ## Possible values: 'redis' or 'hash'
    Lit.key_value_engine = 'redis'
    
    ## Initialize engine
    Lit.init
    ```

5. After doing above and restarting app, point your browser to ```http://app/lit```



### ToDo

* Rewrite initializer
* Rewrite exporter (which is now code from copycopter)
* Support for array types (ie. ```date.abbr_day_names```)
* Support for wysiwyg
* Better cache
* Support for other key value providers (ie. Redis does not support Array types in easy way)
* Integration with ActiveAdmin


### License

Lit is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
