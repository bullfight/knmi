require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "knmi"
  gem.homepage = "http://github.com/bullfight/knmi"
  gem.license = "MIT"
  gem.summary = %Q{Ruby API to access ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE daily climate data}
  gem.description = %Q{Access climatalogical data as provided by the ROYAL NETHERLANDS METEOROLOGICAL INSTITUTE
    through their http get form details of data here (http://www.knmi.nl/climatology/daily_data/scriptxs-en.html) and
    station list here http://www.knmi.nl/climatology/daily_data/scriptxs-en.html, data is parsed into a array of hashes
    with keys for each element { [ "STN" => 210, "YYYMMDD" => 20110427, "TG" => 25 ] } }
  gem.email = "p.schmitz@gmail.com"
  gem.authors = ["bullfight"]
  gem.add_runtime_dependency 'httparty', '>= 0.7.4'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "knmi #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
