#!/usr/bin/env ruby
require 'find'
require 'git'
require 'octokit'
require 'tmpdir'

class Gripst
  attr_reader :tmpdir, :auth_token
  ParamObj = Struct.new(:id, :path)

  def initialize
    @auth_token = ENV['GITHUB_USER_ACCESS_TOKEN']
    puts Dir.methods.grep("tmp").join " "
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

  def create_client
    client = Octokit::Client.new(:access_token => "#{auth_token}")
    client.user.login
    client
  end

  def clone(id)
    Git.clone("https://#{auth_token}@gist.github.com/#{id}.git", id, :path => "#{tmpdir}")
    true
  rescue => e
    $stderr.puts "ERROR: git fell down on #{id}"
    $stderr.puts "ERROR: #{e}"
    false
  end

  def grep_gist(regex, id)
    Find.find("#{tmpdir}/#{id}") do |path|
      param_obj = ParamObj.new(id, path)
      return Find.prune if git_dir? param_obj
      loop_through_lines_of_a_gist(regex, param_obj) if File.file? path
    end if clone id
  end

  private

  def loop_through_lines_of_a_gist(regex, param_obj)
    File.new(param_obj.path).each do |line|
      begin
        matches = /#{regex}/.match(line)
      rescue ArgumentError
        $stderr.puts "Skipping... #{param_obj.id} (#{extract_gistfile_name(param_obj.path)}) #{$!}"
        sleep 300
      end

       matches.nil? ?  'No matches' : display_matches(param_obj, line)
    end
  end

  def display_matches(param_obj, line)
    puts "#{param_obj.id} (#{extract_gistfile_name(param_obj.path)}) #{line}"
  end

  def git_dir?(obj)
    obj.path == "#{tmpdir}/#{obj.id}/.git"
  end

  def extract_gistfile_name(path)
    path.split('/')[-1]
  end
end

################################################################################
begin
  gripst = Gripst.new
  return $stderr.puts "please set GITHUB_USER_ACCESS_TOKEN in env" unless gripst.initialized?
  gripst.all_gist_ids.each { |id| gripst.grep_gist(ARGV[0], id) }
rescue SystemExit, Interrupt
  $stderr.puts 'Bye Bye'
end
