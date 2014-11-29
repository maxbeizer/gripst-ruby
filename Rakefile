require 'bundler/gem_tasks'
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'bundler/version'

task :build do
  system 'gem build gripst.gemspec'
end

task :release => :build do
  system "gem push gripst-#{Gripst::VERSION}"
end
