#!/usr/bin/env ruby
# manifest_diff.rb -- compare a fresh full measurement against the committed
# expectations manifest and report the drift in both directions.
#
# Usage: ruby tools/rubyspec/manifest_diff.rb EXPECTATIONS_TSV RESULTS_TSV
#
# Regressions (manifest says PASS, measurement says otherwise) are the
# retention gate's business; this report exists for the other direction --
# improvements to promote into the manifest -- and for status drift among
# the non-PASS classes (FAIL becoming REJECT etc.), which is informational.
#
# Exit status is always 0: the full measurement is a survey, not a gate.

expect_f, result_f = ARGV
abort "usage: manifest_diff.rb EXPECTATIONS_TSV RESULTS_TSV" unless expect_f && result_f
unless File.exist?(expect_f)
  puts "rubyspec: no expectations manifest at #{expect_f} (bootstrap: copy the results tsv there)"
  exit 0
end

read_tsv = lambda do |path|
  h = {}
  File.foreach(path, mode: "rb") do |line|   # ERROR details are raw bytes
    name, status, = line.chomp.split("\t", 3)
    h[name] = status if name && status
  end
  h
end

expect = read_tsv.call(expect_f)
result = read_tsv.call(result_f)

regressions = []   # PASS expected, something else measured
improvements = []  # non-PASS expected, PASS measured
drift = []         # non-PASS status changed to a different non-PASS status
unlisted = []      # measured but absent from the manifest
missing = []       # listed but not measured

(expect.keys | result.keys).sort.each do |name|
  e, r = expect[name], result[name]
  if e.nil? then unlisted << name
  elsif r.nil? then missing << name
  elsif e == r then next
  # a by-design row is a REJECT or ERROR with a ledger annotation; the raw
  # measurement reports it as plain REJECT or ERROR and that is not drift
  elsif e == "#{r}-BYDESIGN" then next
  elsif e == "PASS" then regressions << [name, r]
  elsif r == "PASS" then improvements << [name, e]
  else drift << [name, e, r]
  end
end

puts "--- manifest drift (#{expect_f}) ---"
puts "regressions:  #{regressions.size}" + (regressions.empty? ? "" : "  <-- fix or explain before updating the manifest")
regressions.first(20).each { |n, r| puts "  #{n}: PASS -> #{r}" }
puts "improvements: #{improvements.size}" + (improvements.empty? ? "" : "  <-- promote by regenerating the manifest")
improvements.first(20).each { |n, e| puts "  #{n}: #{e} -> PASS" }
puts "status drift: #{drift.size} (informational)"
puts "unlisted: #{unlisted.size}, missing: #{missing.size}" if unlisted.any? || missing.any?
