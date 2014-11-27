#!/usr/bin/env ruby
require_relative 'lib/gripst'

begin
  gripst = Gripst.new
  $stderr.puts "please set GITHUB_USER_ACCESS_TOKEN in env" unless gripst.initialized?
  puts 'gripsting'
  gripst.all_gist_ids.each { |id| gripst.run(ARGV[0], id) }
rescue SystemExit, Interrupt
  $stderr.puts 'Bye Bye'
end
