rails-data-explorer
===================

rails-data-explorer is a Rails Engine plugin that makes it easy to explore the
data in your app using charts and statistics.

Make sure to go to the thorough [documentation](http://rails-data-explorer.clearcove.ca)
to find out more!

## IMPORTANT NOTE

This gem is under active development and will see significant changes until it's
officially released.

### Installation

`gem install rails-data-explorer`

or with bundler in your Gemfile:

`gem 'rails-data-explorer'`


### Concepts

* Exploration - top level container
* DataSet - like a spreadsheet with one or more columns of data
* DataSeries - like a column in a spreadsheet, with multiple rows of data
* DataType - Each DataSeries contains data of a certain type.
    * Categorical
    * Quantitative
        * Integer
        * Decimal
        * Temporal
    * Geo
* Chart -


### Resources

* [Documentation](http://rails-data-explorer.clearcove.ca)
* [Live demo](http://rails-data-explorer-demo.herokuapp.com)
* [Changelog](https://github.com/jhund/rails-data-explorer/blob/master/CHANGELOG.md)
* [Source code (github)](https://github.com/jhund/rails-data-explorer)
* [Issues](https://github.com/jhund/rails-data-explorer/issues)
* [Rubygems.org](http://rubygems.org/gems/rails-data-explorer)

### License

[MIT licensed](https://github.com/jhund/rails-data-explorer/blob/master/MIT-LICENSE).



### Copyright

Copyright (c) 2014 Jo Hund. See [(MIT) LICENSE](https://github.com/jhund/rails-data-explorer/blob/master/MIT-LICENSE) for details.
