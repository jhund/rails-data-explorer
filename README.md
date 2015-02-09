# rails-data-explorer

Rails-data-explorer is a Rails Engine plugin that makes it easy to explore the
data in your app using charts and statistics.

All you have to do is to throw your data in table form at rails-data-explorer.
Rails-data-explorer then analyzes your data and automatically renders suitable
charts and descriptive statistics for each column. It offers tools for uni-, bi-
and multi-variate analysis. It can even find correlations in your categorical data
using Pearson's Chi Squared test.

See below for a screenshot of what you get.

### Installation

`gem install rails-data-explorer`

or with bundler in your Gemfile:

`gem 'rails-data-explorer'`


### Usage

Let's say you want to explore your app's `User` signup data. Create a route and action
named 'signups' in `app/controllers/users_controller.rb`:

~~~ ruby
def signups
  # DANGER! Make sure not to load too much data into memory!
  user_data = User.all.to_a

  c_binner = RailsDataExplorer::Utils::DataBinner.new(
    '0' => 0,
    '1' => 1,
    '2' => 2,
    '3..10' => 10,
    '11..100' => 100,
    '101..1,000' => 1000,
    '1,001..10,000' => 10000
  )
  @rails_data_explorer = RailsDataExplorer.new(
    user_data,
    [
      {
        name: "Session duration [Minutes]",
        data_method: Proc.new { |row|
          ((row.session_duration_minutes * 100).round)/100.0
        },
      },
      {
        name: "Country",
        data_method: Proc.new { |row| row.country },
        multivariate: ['All'],
      },
      {
        name: "Sign in count",
        data_method: Proc.new { |row| c_binner.bin(row.sign_in_count) },
      },
      {
        name: "Language",
        data_method: Proc.new { |row| row.language },
        multivariate: ['All'],
      },
      {
        name: "Plan",
        data_method: Proc.new { |row| row.plan },
        multivariate: ['All'],
      },
      {
        name: "Sign up date",
        data_method: Proc.new { |row| row.created_at },
      },
      {
        name: "Sign up quarter",
        data_method: Proc.new { |row|
          year = row.created_at.year
          quarter = (row.created_at.month / 3.0).ceil
          "#{ year } / Q#{ quarter }"
        },
      },
    ]
  )
end
~~~

Then create a view at `app/views/users/signups.html.erb`:

~~~erb
<div class="rails-data-explorer">
  <h1>User signup data</h1>
  <%= @rails_data_explorer.render %>
</div>
~~~

With just a few lines of code you get comprehensive statistics and charts for your data:

***

![Rails data exploration](https://github.com/jhund/rails-data-explorer/blob/master/doc/rails-data-explorer-screenshot.png)

***


### Ways to shoot yourself in the foot

* **Loading too many DB rows at once**: Remember that you are loading ActiveRecord
  objects, and they can use a lot of ram. It's a cartesian product of number of
  rows times columns per record. As a rule of thumb, for a medium sized model with
  30 columns, you can load up to 10,000 rows.
* **Using expensive operations in the `:data_method` option for a given data series**:
  As a rule of thumb, it should be ok to run simple methods that don't require
  DB access. Examples: `#.to_s`, `if` and `case`, and math operations should all
  be fine.
* **Declaring too many charts**: The charts rendered are the sum of the following:
    * univariate: one or more charts for each data series
    * bivariate: the cartesian product of all data series in a bivariate group
    * multivariate: one or more charts for each multivariate group
  I have tested it with 70 charts on a single page. More are probably ok, I
  just haven't tested it.
* **Drowning in detail**: rails-data-explorer makes it easy to generate a large
  number of charts. Make sure you don't miss the important data in the noise.


### Dependencies

* ActionView >= 3.0
* ActiveSupport >= 3.0
* Asset pipeline (for batteries included, otherwise you'll have to pull in a number of assets manually)
* jQuery??

### Resources

* [Changelog](https://github.com/jhund/rails-data-explorer/blob/master/CHANGELOG.md)
* [Source code (github)](https://github.com/jhund/rails-data-explorer)
* [Issues](https://github.com/jhund/rails-data-explorer/issues)
* [Rubygems.org](http://rubygems.org/gems/rails-data-explorer)
* [API documentation](http://www.rubydoc.info/gems/rails-data-explorer/)

[![Build Status](https://travis-ci.org/jhund/rails-data-explorer.svg?branch=master)](https://travis-ci.org/jhund/rails-data-explorer)

### License

[MIT licensed](https://github.com/jhund/rails-data-explorer/blob/master/MIT-LICENSE).



### Copyright

Copyright (c) 2015 Jo Hund. See [(MIT) LICENSE](https://github.com/jhund/rails-data-explorer/blob/master/MIT-LICENSE) for details.
