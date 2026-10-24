#!/usr/bin/env spinel
# spinel: not-cruby
# CRuby, run as `ruby FILE`, takes a first-line shebang that does not name
# ruby as `ruby -x` would and finds no Ruby script (LoadError); Spinel
# compiles the entry file as written. Its requires in a dead branch name no
# file and are dropped, as in any entry file: the file's own parse, which
# the dead-require fold reads, must not take the shebang that way (#9898).
if false
  require_relative "no_such_file_xyz"
end
if false
  require "no_such_lib_xyz"
end
puts 2
