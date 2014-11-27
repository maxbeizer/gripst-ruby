#!/usr/bin/env ruby
require 'find'
require 'git'
require 'octokit'
require 'tmpdir'
require_relative 'string'

class Gripst
  attr_reader :tmpdir, :auth_token
  ParamObj = Struct.new(:id, :path)

  def initialize
    @auth_token = ENV['GITHUB_USER_ACCESS_TOKEN']
    @tmpdir = Dir.mktmpdir
  end

  def initialized?
    !!auth_token
  end

  def all_gist_ids
    client.gists.map(&:id)
  end

  def client
    @client ||= create_client
  end

  def clone(id)
    Git.clone("https://#{auth_token}@gist.github.com/#{id}.git", id, :path => "#{tmpdir}")
    true
  rescue => e
    $stderr.puts "ERROR: git fell down on #{id}"
    $stderr.puts "ERROR: #{e}"
    false
  end

  def run(regex, id)
    Find.find("#{tmpdir}/#{id}") do |path|
      param_obj = ParamObj.new(id, path)
      return Find.prune if git_dir? param_obj
      loop_through_lines_of_a_gist(regex, param_obj) if File.file? path
    end if clone id
  end

  private

  def create_client
    client = Octokit::Client.new(:access_token => "#{auth_token}")
    client.user.login
    client
  end

  def loop_through_lines_of_a_gist(regex, param_obj)
    File.new(param_obj.path).each do |line|
      begin
        display_match(param_obj, line) if /#{regex}/.match line
      rescue ArgumentError
        $stderr.puts "Skipping... #{output_info_string(param_obj)} #{$!}"
        sleep 300
      end
    end
  end

  def display_match(param_obj, line)
    puts "#{output_info_string(param_obj)} #{line}"
  end

  def git_dir?(obj)
    obj.path == "#{tmpdir}/#{obj.id}/.git"
  end

  def output_info_string(param_obj)
    "#{param_obj.id.pink} (#{extract_gistfile_name(param_obj.path)})"
  end

  def extract_gistfile_name(path)
    path.split('/')[-1].yellow
  end
end

################################################################################
begin
  gripst = Gripst.new
  $stderr.puts "please set GITHUB_USER_ACCESS_TOKEN in env" unless gripst.initialized?
  puts 'gripsting'
  gripst.all_gist_ids.each { |id| gripst.run(ARGV[0], id) }
rescue SystemExit, Interrupt
  $stderr.puts 'Bye Bye'
end
