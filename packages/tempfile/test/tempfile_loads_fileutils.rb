# CRuby's tempfile requires tmpdir, and tmpdir requires fileutils, so a
# program that only requires tempfile can name FileUtils. The same chain
# loads here: no `require "fileutils"` appears in this file.
require "tempfile"

Dir.mktmpdir("spinel-chain-") do |d|
  FileUtils.mkdir_p("#{d}/a/b")
  FileUtils.touch(["#{d}/a/b/one.rb", "#{d}/a/two.rb"])
  p Dir.glob("#{d}/**/*.rb").map { |f| f.delete_prefix("#{d}/") }.sort
  FileUtils.rm_rf("#{d}/a")
  p Dir.exist?("#{d}/a")
end

# Tempfile itself still works alongside it
Tempfile.create("chain") do |f|
  f.write("x")
  f.flush
  p File.size(f.path)
end
