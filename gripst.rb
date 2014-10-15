#!/usr/bin/env ruby
require 'find'
require 'git'
require 'octokit'
require 'tmpdir'

class Gripst

  def initialize
    @auth_token = ENV['GITHUB_USER_ACCESS_TOKEN']
    puts Dir.methods.grep("tmp").join " "
    @tmpdir = Dir.mktmpdir
  end

  def initialized?
    !!@auth_token
  end

  def all_gist_ids
    client.gists.map(&:id)
  end

  def client
    @client ||= create_client
  end

  def create_client
    Octokit.auto_paginate = true
    client = Octokit::Client.new(:access_token => "#{@auth_token}")
    octouser = client.user
    octouser.login
    client
  end

  def clone(id)
    begin
      g = Git.clone("https://#{@auth_token}@gist.github.com/#{id}.git", id, :path => "#{@tmpdir}")
    rescue
      $stderr.puts "ERROR: git fell down on #{id}"
      return false
    end
    return true
  end

  def grep_gist(regex,id)
    if clone(id)
      Find.find("#{@tmpdir}/#{id}") do |path|
      if path == "#{@tmpdir}/#{id}/.git"
          Find.prune
        else
          if File.file?(path)
            fh = File.new(path)
            fh.each do |line|
              begin
                matches = /#{regex}/.match(line)
              rescue ArgumentError
                $stderr.puts "Skipping... #{id}(#{(path).gsub("#{@tmpdir}/#{id}/","")}) #{$!}"
                sleep 300
              end
              if matches != nil
                puts "#{id} (#{(path).gsub("#{@tmpdir}/#{id}/","")}) #{line}"
              end
            end
          end
        end
      end
    end
  end

end

################################################################################
begin
  gripst = Gripst.new
  if gripst.initialized?
    gripst.all_gist_ids.each do |id|
      gripst.grep_gist(ARGV[0],id)
    end
  else
    $stderr.puts "please set GITHUB_USER_ACCESS_TOKEN in env"
  end
rescue SystemExit, Interrupt
  $stderr.puts "Ok."
end
