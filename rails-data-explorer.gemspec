# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'rails-data-explorer'
  gem.version = '1.0.1'
  gem.platform = Gem::Platform::RUBY

  gem.authors = ['Jo Hund']
  gem.email = 'jhund@clearcove.ca'
  gem.homepage = 'https://github.com/jhund/rails-data-explorer'
  gem.licenses = ['MIT']
  gem.summary = 'A Rails engine plugin for exploring data in your app with charts and statistics.'
  gem.description = %(rails-data-explorer is a Rails Engine plugin that makes it easy to explore the data in your app using charts and statistics.)

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.add_dependency 'rails', '>= 3.1.0'
  gem.add_dependency 'color', '~> 1.7', '>= 1.7.1'
  gem.add_dependency 'descriptive-statistics', '~> 2.1', '>= 2.1.2'
  gem.add_dependency 'distribution', '~> 0.7', '>= 0.7.1'
  gem.add_dependency 'interpolate', '~> 0.3', '>= 0.3.0'

  gem.add_development_dependency 'bundler', '~> 1.0', '>= 1.0.0'
  gem.add_development_dependency 'minitest', '>= 0'
  gem.add_development_dependency 'minitest-spec-expect', '>= 0'
  gem.add_development_dependency 'rake', '>= 0'
end
