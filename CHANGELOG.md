# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [Unreleased]



## [0.3.3] - 2018-04-05
### Added
- Inline editing [@mlitwiniuk](https://github.com/mlitwiniuk)
- Support Rails 4.2-5.0 and Ruby 2.3-2.4 [@mlitwiniuk](https://github.com/mlitwiniuk) & [@zhisme](https://github.com/zhisme)
- Support Rails 5.1 [@mlitwiniuk](https://github.com/mlitwiniuk)

### Changed
- Sync only UI modified keys [@vincentvanbush](https://github.com/vincentvanbush)
- Asynchronous loading of translations synchronized via API [@vincentvanbush](https://github.com/vincentvanbush)
- Better caching [@mlitwiniuk](https://github.com/mlitwiniuk)
- Streamline installation process (no migration copying) [@mlitwiniuk](https://github.com/mlitwiniuk)
- Loosen I18n dependency

### Fixed
- Fix/yaml translations overwriting [@vincentvanbush](https://github.com/vincentvanbush)

### Removed
- Support for Rails <4.2

## [0.2.6] - 2016-05-12
### Added
- Infer underscore key names from space-separated search queries [@vincentvanbush](https://github.com/vincentvanbush)
- Various optimizations

## [0.2.5] - 2015-11-19
### Added
- Ignoring key prefixes [@mlitwiniuk](https://github.com/mlitwiniuk)

### Changed
- Various refactoring and optimizations [@Bonias](https://github.com/Bonias) & [@mlitwiniuk](https://github.com/mlitwiniuk)
- Move Lit panel to Bootstrap 3 [@mlitwiniuk](https://github.com/mlitwiniuk)

### Fixed
- Only save translations for locales defined in available_locales [@stephanvane](https://github.com/stephanvane)

## [0.2.1] - 2013-10-18
### Changed
- Use Arel to create SQL searches [@Bonias](https://github.com/Bonias)

### Fixed
- Fix array translations updating [@Bonias](https://github.com/Bonias)

## [0.2.0] - 2013-10-11
### Added
- jQuery TE as WYSIWYG editor [@mlitwiniuk](https://github.com/mlitwiniuk)
- Sorting of localization keys [@Bonias](https://github.com/Bonias)

### Changed
- Updates to License
- Initial loading improvements [@Bonias](https://github.com/Bonias)
- Performance improvements [@Bonias](https://github.com/Bonias)
- Pure I18n compatibility [@Bonias](https://github.com/Bonias)

### Fixed
- Submit button breaking when translation missing message appears [@Bonias](https://github.com/Bonias)

### Removed
- Support for default Proc values [@mlitwiniuk](https://github.com/mlitwiniuk)

## [0.1.0] - 2013-09-25
### Added
- Support nil values
- Install generator
- API, groundwork for syncing keys between environments
- Syncing keys between envs

### Changed
- Improvements to Array support
- Updates to Readme

## [0.0.4.3] - 2013-09-18
### Added
- Export tasks
- Setting default text
- Arrays support
- Hit counters for translation keys
- Locale can be hidden
- Translation fallbacks

### Changed
- Refactoring and cleanup

## 0.0.4 - 2013-01-15
- Prefixing Redis storage keys
- Rails 4 compatibility
- Further development

## 0.0.3.1 - 2012-12-31
- Updates to gemspec and readme. Added License

## 0.0.3 - 2012-12-31
- Initial release

[Unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v1.0.0...HEAD
[0.3.3]: https://github.com/prograils/lit/compare/v0.2.6...v0.3.3
[0.2.6]: https://github.com/prograils/lit/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/prograils/lit/compare/v0.2.1...v0.2.5
[0.2.1]: https://github.com/prograils/lit/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/prograils/lit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/prograils/lit/compare/v0.0.4.3...v0.1.0
[0.0.4.3]: https://github.com/prograils/lit/compare/98b331975dfad4b4a01a290a9d27abdfa9db17f0...v0.0.4.3
