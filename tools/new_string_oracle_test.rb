#!/usr/bin/env ruby
# Self-test of tools/new_string_oracle.rb that needs no compiler bug: each
# test/new-string-oracle/NAME.rb is checked against its hand-written or
# recorded NAME.claims (--claims), and the tool must disprove exactly the
# claims the file's "# disproved: KIND LINE:COL" lines name. true_and_false_claims
# holds a true and a false claim of each check; the other fixtures are the
# claims past compilers made for programs they got wrong.
require "json"
require "open3"
require "rbconfig"

root = File.expand_path("..", __dir__)
dir = File.join(root, "test", "new-string-oracle")
tool = File.join(root, "tools", "new_string_oracle.rb")
failures = []
claims_files = Dir.glob(File.join(dir, "*.claims")).sort
failures << "no fixtures in #{dir}" if claims_files.empty?

claims_files.each do |claims|
  name = File.basename(claims, ".claims")
  prog = File.join(dir, "#{name}.rb")
  want = File.readlines(claims, chomp: true).filter_map { |l| l[/\A# disproved: (.+)/, 1] }.sort
  out, err, st = Open3.capture3(RbConfig.ruby, "--enable-frozen-string-literal", tool, "--json", "--claims", claims, prog)
  rep = (JSON.parse(out).first rescue nil)
  unless rep
    failures << "#{name}: no report (#{st.exitstatus}): #{err.lines.first}"
    next
  end
  failures << "#{name}: status #{rep["status"]} #{rep["notes"].inspect}" unless rep["status"] == "checked"
  failures << "#{name}: perturbed (#{rep["perturbed"]})" if rep["perturbed"]
  failures << "#{name}: the oracle failed itself (#{rep["oracle_error"]})" if rep["oracle_error"]
  got = rep["claims"].select { |c| c["disproved"] > 0 }.map { |c| c["site"].split(" ").first.split(":")[1, 2].join(":").then { |lc| "#{c["kind"]} #{lc}" } }.sort
  failures << "#{name}: disproved #{got.inspect}, want #{want.inspect}" unless got == want
  failures << "#{name}: exit status #{st.exitstatus}, want #{want.empty? ? 0 : 1}" unless st.exitstatus == (want.empty? ? 0 : 1)
  # a claim the file lists as true must have been reached and checked
  unreached = rep["claims"].select { |c| c["check"] != "none" && !c["reached"] }.map { |c| "#{c["kind"]} #{c["site"]}" }
  unreached -= rep["unprobed"].map { |i, _| "#{rep["claims"][i]["kind"]} #{rep["claims"][i]["site"]}" } if rep["unprobed"]
  failures << "#{name}: claims never reached: #{unreached.first(3).inspect}" if %w[true_and_false_claims unkept_claims walk_robustness unshared_claims frozen_claims].include?(name) && !unreached.empty?
end

# the kinds are read as data: one with no check, and one with a check the
# tool does not know, are reported and checked as `new`; check=none is not checked
claims = File.join(dir, "true_and_false_claims.claims")
out, = Open3.capture3(RbConfig.ruby, "--enable-frozen-string-literal", tool, "--claims", claims, File.join(dir, "true_and_false_claims.rb"))
failures << "an unstated check is not reported" unless out.include?("kinds with no stated check (checked as new): mystery")
failures << "an unknown check is not reported" unless out.include?('claim kind odd: unknown check "weird"')
failures << "a check=none claim was checked" unless out.match?(/^\s+skipped\s+none\s+1\s+0\s+0\s+0$/)

# unkept is a method check: on a call it is reported, not run
out, = Open3.capture3(RbConfig.ruby, "--enable-frozen-string-literal", tool, "--claims", File.join(dir, "unkept_claims.claims"),
                      File.join(dir, "unkept_claims.rb"))
failures << "an unkept claim on a call is not reported" unless out.include?("unprobed: 1 unkept claim on no method")

if failures.empty?
  puts "new-string-oracle-selftest: pass (#{claims_files.size} fixtures)"
else
  puts failures.map { |f| "new-string-oracle-selftest: FAIL #{f}" }
  exit 1
end
