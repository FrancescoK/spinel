#!/usr/bin/env ruby
# frozen_string_literal: true
# Focused checks of the observation machinery, independent of compiler rows.
require_relative "gen_builtin_share_spec"

checks = 0
Dir.mktmpdir("builtin-share-test") do |dir|
  Dir.chdir(dir) do
    tests = [
      ["String", "capitalize", -> { +"ab" }, 0, 1],
      ["String", "downcase!", -> { +"ab" }, 0, 1],
      ["String", "squeeze!", -> { +"ab" }, 0, 1],
      ["String", "delete_suffix!", -> { +"ab" }, 0, 1],
      ["StringRange", "step", -> { "a".."b" }, 2, 2],
      ["String", "partition", -> { +"ab" }, 0, 4],
      ["String", "each_line", -> { +"ab" }, 2, 1],
      ["String", "[]=", -> { +"ab" }, 0, 8],
      ["Array", "push", -> { [] }, 1, 4],
      ["Array", "concat", -> { [] }, 1, 4],
      ["String", "replace", -> { +"ab" }, 3, 1],
      ["File", "sum", INSTANCE_RECEIVERS["File"], 0, 4],
      ["Queue", "push", INSTANCE_RECEIVERS["Queue"], 1, 4],
      ["Array", "sum", -> { [] }, 0, 4],
      ["Range", "inject", -> { 1..2 }, 2, 4],
      ["Kernel.", "throw", -> { Kernel }, 0, 8],
      ["ENV.", "store", -> { ENV }, 0, 8]
    ]
    tests.each do |cls, name, factory, channel, bit|
      r = BuiltinShareProbe.probe(cls, name, factory)
      abort "missing observation: #{cls} #{name}" if r["ok"].zero? || r["effects"][channel] & bit == 0
      abort "successful shapes lost" unless r["cases"].sum { |c| c["ok"] } == r["ok"]
      checks += 2
    end
    r = BuiltinShareProbe.probe("String", "bytesize", -> { +"ab" })
    abort "a read acquired identity" unless r["effects"].all?(&:zero?)
    checks += 1
    r = BuiltinShareProbe.probe("Object", "__share_no_such_method__", -> { Object.new })
    abort "failed calls were classified" unless r["ok"].zero? && r["cases"].empty?
    checks += 1
  ensure
    ENV.delete("SPINEL_SHARE_ORACLE")
  end
end
source = File.read(File.join(BuiltinShareProbe::ROOT, "src/builtin_ops.c"))
hand = source.scan(/\{\s*(\w+),\s*"([^"]+)",\s*BSH_\w+/).map { |fam, name| [fam, name] }
pure = File.read(BuiltinShareProbe::PURE).scan(/\{\s*(\w+),\s*"([^"]+)",\s*BSH_PURE/)
abort "generated rows duplicate hand rows" unless (hand & pure).empty?
checks += 1
puts "builtin-share-spec-test: #{checks} checks passed"
