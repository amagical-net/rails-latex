require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "rails-latex"
    s.summary = "A LaTeX to pdf rails 3 renderer."
    s.description = "rails-latex is a renderer for rails 3 which allows tex files with erb to be turned into an inline pdf."
    s.email = "geoffjacobsen@gmail.com"
    s.authors = ["Geoff Jacobsen"]
    s.files =Dir.glob("{init.rb,MIT-LICENSE,{lib,test}/**/*}")
    s.add_dependency 'rails', '>= 3.0.0.beta3'
    s.extra_rdoc_files='{README.rdoc,MIT-LICENSE}'
    s.rdoc_options << "--main=README.rdoc"
    s
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Rails-LaTeX #{version}"
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
