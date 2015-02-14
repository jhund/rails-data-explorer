# encoding: utf-8
begin
  require 'bundler'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.libs.push "spec"
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
end

task :default => ['test']

require 'yui/compressor'

namespace :rde do

  def minify_js(output_file_name, file_list)
    uncompressed_source = ''
    file_list.each do |file|
      uncompressed_source << File.read(file)
    end
    compressor = YUI::JavaScriptCompressor.new
    compressed_output = compressor.compress(uncompressed_source)
    File.write(output_file_name, compressed_output)
  end

  def minify_css(output_file_name, file_list)
    uncompressed_source = ''
    file_list.each do |file|
      uncompressed_source << File.read(file)
    end
    compressor = YUI::CssCompressor.new
    compressed_output = compressor.compress(uncompressed_source)
    File.write(output_file_name, compressed_output)
  end

  desc "minify"
  task :minify => [:minify_js, :minify_css]

  desc "minify javascript"
  task :minify_js do
    base_path = File.expand_path("../vendor/assets/javascripts", __FILE__)
    minify_js(
      File.join(base_path, 'packaged/rails-data-explorer.min.js'),
      [
        File.join(base_path, 'rails-data-explorer/d3.v3.js'),
        # File.join(base_path, 'rails-data-explorer/nv.d3.js'),
        File.join(base_path, 'rails-data-explorer/d3.boxplot.js'),
        File.join(base_path, 'rails-data-explorer/d3.parcoords.js'),
        File.join(base_path, 'rails-data-explorer/d3.parsets.js'),
        File.join(base_path, 'rails-data-explorer/vega.js'),
      ]
    )
  end

  desc "minify css"
  task :minify_css do
    base_path = File.expand_path("../vendor/assets/stylesheets", __FILE__)
    minify_css(
      File.join(base_path, 'packaged/rails-data-explorer.min.css'),
      [
        File.join(base_path, 'rails-data-explorer/bootstrap-theme.css'),
        File.join(base_path, 'rails-data-explorer/bootstrap.css'),
        File.join(base_path, 'rails-data-explorer/d3.boxplot.css'),
        File.join(base_path, 'rails-data-explorer/d3.parcoords.css'),
        File.join(base_path, 'rails-data-explorer/d3.parsets.css'),
        # File.join(base_path, 'rails-data-explorer/nv.d3.css'),
        File.join(base_path, 'rails-data-explorer/rde-default-style.css'),
      ]
    )
  end

end
