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


### Ways to shoot yourself in the foot

* Loading too many DB rows at once: Remember that you are loading ActiveRecord
  objects, and they can use a lot of ram. It's a cartesian product of number of
  rows times columns per record. As a rule of thumb, for a medium sized model with
  30 columns, you can load up to 10,000 rows.
* Using expensive operations in the :data_method option for a given data series.
  As a rule of thumb, it should be ok to run simple methods that don't require
  DB access. Examples: `#.to_s`, `if` and `case`, and math operations.
* Declaring too many charts: The charts rendered are the sum of the following:
    * univariate: one or more charts for each data series
    * bivariate: the cartesian product of all data series in a bivariate group
    * multivariate: one or more charts for each multivariate group
  I have tested it with 70 charts on a single page. More are probably ok, I
  just haven't tested it.
* Drowning in detail. rde makes it easy to generate a large number of charts.
  Make sure you don't miss the important data in the noise.

### Dependencies

* ActionView >= 3.0
* ActiveSupport >= 3.0
* Asset pipeline (for batteries included, otherwise you'll have to pull in a number of assets manually)
* jQuery??

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
