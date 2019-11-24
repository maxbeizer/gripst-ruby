# frozen_string_literal: true

require 'bundler/gem_tasks'
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'bundler/version'

Dir.glob('tasks/**/*.rake').each(&method(:import))

task :default => [:spec]
