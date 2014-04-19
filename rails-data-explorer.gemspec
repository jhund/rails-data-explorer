# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'rails-data-explorer'
  gem.version = '0.0.3'
  gem.platform = Gem::Platform::RUBY

  gem.authors = ['Jo Hund']
  gem.email = 'jhund@clearcove.ca'
  gem.homepage = 'http://rails-data-explorer.clearcove.ca'
  gem.licenses = ['MIT']
  gem.summary = 'A Rails engine plugin for exploring data in your app with charts and statistics.'
  gem.description = %(rails-data-explorer is a Rails Engine plugin that makes it easy to explore the data in your app using charts and statistics.)

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  gem.add_dependency 'color'
  gem.add_dependency 'descriptive-statistics'
  gem.add_dependency 'distribution'
  gem.add_dependency 'interpolate'

  gem.add_development_dependency 'actionview', '>= 3.0.0'
  gem.add_development_dependency 'bundler', ['>= 1.0.0']
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'minitest-spec-expect'
  gem.add_development_dependency 'rake', ['>= 0']
  gem.add_development_dependency 'yui-compressor'
end
