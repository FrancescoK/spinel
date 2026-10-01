#!/usr/bin/env ruby
# promise_diff.rb -- what changed in the PROMISE surface between two commits.
#
# Usage: ruby tools/promise_diff.rb [FROM [TO]]
#        FROM defaults to the latest release tag, TO to HEAD.
#
# A release name says when a release was cut, not how finished it is (see
# docs/spin.md). What it is allowed to say is what has stopped being allowed to
# change, and that is only checkable if "promised" is narrower than "true". It
# is: a behaviour nothing pins is true by accident, and changing it breaks
# nobody's expectation because nobody was given one. The promise surface is the
# part that is written down.
#
# Five places hold it, and all five are readable from git alone -- no build, so
# this runs over any range, including ones already in the past:
#
#   1. test/ and packages/*/test/ *.expected   an answer a test pins
#   2. tools/rubyspec/expectations/*.tsv   the PASS rows the retention gate keeps
#   3. docs/limitations.md  the catalogue of what spinel deliberately does not do
#   4. tools/spin.rb        the spin.toml fields a manifest may set
#   5. src/main.c           the compiler flags a command line may pass
#
# What it cannot see is a promise nobody wrote down -- carried C was compiled
# by presence for years and that was a contract for everyone with a .c in their
# tree, with nothing anywhere saying so (#4362). Those arrive as bug reports.
# When one does, the fix is to write it down, and from then on it is here.
#
# Exit status is always 0: this is a survey, like tools/rubyspec/manifest_diff.rb.
# Whether a break is acceptable is a judgement, and the report exists to put it
# in front of someone rather than to answer it.

def sh(cmd)
  out = `#{cmd} 2>/dev/null`
  $?.success? ? out : nil
end

# File content at a revision; nil when the path did not exist there.
def at(rev, path)
  sh("git show #{rev}:#{path}")
end

def rev_ok?(rev)
  !sh("git rev-parse --verify --quiet #{rev}^{commit}").to_s.strip.empty?
end

# The release tags, oldest first. The pattern IS the format rule (docs/spin.md):
# YYYY.MM.DD with an optional .N for a second release on one day. A tag shaped
# any other way is not a release.
def release_tags
  sh("git tag").to_s.split("\n").grep(/\A\d{4}\.\d{2}\.\d{2}(\.\d+)?\z/).sort_by do |t|
    t.split(".").map { |p| p.to_i }
  end
end

# ---- 1. answers a test pins ---------------------------------------------------
# A .expected that CHANGED is a promised answer that moved. One that was ADDED
# is a new promise, and one that was REMOVED is a promise withdrawn. The
# distinction matters more than it looks: a behaviour change that touches no
# .expected -- predicate blocks stopping early (#4379) -- was never promised,
# only true.
# A modified .expected is not automatically a break: extending a test appends
# cases, and every answer that was already pinned still reads the same. The
# check is whether the old file is a PREFIX of the new one -- an append leaves
# the earlier lines untouched, a changed answer does not. Getting this wrong
# would bury the real signal, since extending a test is the common case and
# changing a pinned answer is rare (none in 200 commits at the time this was
# written).
def appended_only?(from, to, path)
  a = at(from, path)
  b = at(to, path)
  return false if a.nil? || b.nil?
  b.start_with?(a)
end

def pinned_answers(from, to)
  broke = []
  added = []
  gone = []
  extended = []
  # Both trees: a bundled package's tests joined the compiler gate deliberately
  # (b8e9a198 -- "a compiler change that breaks one must fail here, not at
  # package-publish time"), so their expectations are the compiler's promises
  # too. Looking only at test/ missed 51 of them, and missed the first real
  # break this tool was asked about (#4387).
  sh("git diff --name-status #{from} #{to} -- 'test/*.expected' 'packages/*/test/*.expected'").to_s.each_line do |ln|
    st, path = ln.strip.split("\t", 2)
    next if path.nil?
    case st[0]
    when "M" then appended_only?(from, to, path) ? extended << path : broke << path
    when "A" then added << path
    when "D" then gone << path
    end
  end
  [broke, added, gone, extended]
end

# ---- 2. the rubyspec retention contract ---------------------------------------
# name<TAB>status, '#' comments. PASS rows are what `make rubyspec-gate` keeps
# passing; every other status records the frontier. A PASS that stops being one
# is a promise broken whatever the new status says, but PASS -> REJECT-BYDESIGN
# or ERROR-BYDESIGN is a deliberate withdrawal (those rows pair with
# docs/limitations.md), so it is reported apart from a regression.
def spec_rows(rev, file)
  txt = at(rev, "tools/rubyspec/expectations/#{file}")
  rows = {}
  return rows if txt.nil?
  txt.each_line do |ln|
    next if ln.start_with?("#")
    name, status = ln.chomp.split("\t", 2)
    next if name.nil? || status.nil? || name.empty?
    rows[name] = status
  end
  rows
end

def spec_files(rev)
  sh("git ls-tree -r --name-only #{rev} -- tools/rubyspec/expectations")
    .to_s.split("\n").map { |p| File.basename(p) }.select { |p| p.end_with?(".tsv") }
end

def rubyspec(from, to)
  regressed = []
  withdrawn = []
  gained = []
  (spec_files(from) | spec_files(to)).sort.each do |f|
    a = spec_rows(from, f)
    b = spec_rows(to, f)
    a.each do |name, st|
      next unless st == "PASS"
      now = b[name]
      if now.nil?
        regressed << [f, name, "row removed"]
      elsif now.end_with?("-BYDESIGN")
        withdrawn << [f, name, now]
      elsif now != "PASS"
        regressed << [f, name, now]
      end
    end
    b.each do |name, st|
      gained << [f, name] if st == "PASS" && a[name] != "PASS"
    end
  end
  [regressed, withdrawn, gained]
end

# ---- 3. the limitations catalogue ---------------------------------------------
# The catalogue states an entry in one of two forms, and both count: a row in a
# markdown table (the first cell names the feature), and a "####" subsection for
# one that needs a paragraph -- the two Set divergences the recursion guard
# introduces are written that way. Reading only the tables missed those.
#
# Headings down to "###" are sections rather than entries, and the section is
# reported with the entry because it carries the direction: a row under "Now
# supported" is the opposite of a row under "Fundamental limits". That is left
# to the reader rather than guessed at here.
def limitation_rows(rev)
  txt = at(rev, "docs/limitations.md")
  rows = {}
  return rows if txt.nil?
  section = "(top)"
  txt.each_line do |ln|
    l = ln.chomp
    if l.start_with?("####")
      rows[l.sub(/\A#+\s*/, "")] = section
      next
    end
    if l.start_with?("#")
      section = l.sub(/\A#+\s*/, "")
      next
    end
    next unless l.start_with?("|")
    cells = l.split("|").map { |c| c.strip }
    cells.shift if cells.first == ""
    feature = cells.first.to_s
    next if feature.empty?
    next if feature.match?(/\A-+\z/)          # the |---|---| separator
    next if feature == "Feature"              # the header row
    rows[feature] = section
  end
  rows
end

def limitations(from, to)
  a = limitation_rows(from)
  b = limitation_rows(to)
  added = b.reject { |k, _| a.key?(k) }.map { |k, s| [k, s] }
  removed = a.reject { |k, _| b.key?(k) }.map { |k, s| [k, s] }
  moved = b.select { |k, s| a.key?(k) && a[k] != s }.map { |k, s| [k, a[k], s] }
  [added, removed, moved]
end

# ---- 4. the manifest fields spin reads ----------------------------------------
# A field spin stops reading is a manifest that silently means something else.
# The set is what the TOML reader is asked for, which is the authority: a field
# documented but never read is not a promise, and one read but undocumented is.
def manifest_keys(rev)
  txt = at(rev, "tools/spin.rb").to_s
  keys = {}
  txt.scan(/\b(?:get|get_array)\(\s*"([^"]*)"\s*,\s*"([^"]+)"/) { |t, k| keys["#{t.empty? ? '(top)' : t}.#{k}"] = true }
  txt.scan(/\bget_inline\(\s*"([^"]*)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"/) { |t, k, ik| keys["#{t.empty? ? '(top)' : t}.#{k}.#{ik}"] = true }
  keys.keys.sort
end

# ---- 5. the compiler's command line -------------------------------------------
# A flag that stops being accepted is a build command that stops working.
def compiler_flags(rev)
  txt = at(rev, "src/main.c").to_s
  flags = {}
  txt.scan(/sp_streq\(\s*a\s*,\s*"(-[^"]+)"/) { |f| flags[f[0]] = true }
  txt.scan(/strncmp\(\s*a\s*,\s*"(--[^"]+=)"/) { |f| flags[f[0]] = true }
  flags.keys.sort
end

# ---- report -------------------------------------------------------------------

from = ARGV[0]
to = ARGV[1] || "HEAD"

if from.nil?
  tags = release_tags
  if tags.empty?
    $stderr.puts "promise-diff: no release tag yet, so there is no baseline to compare against."
    $stderr.puts "              Name one explicitly:  ruby tools/promise_diff.rb <from> [<to>]"
    $stderr.puts "              Release tags are YYYY.MM.DD[.N] (docs/spin.md)."
    exit 0
  end
  from = tags.last
end

[from, to].each do |r|
  unless rev_ok?(r)
    $stderr.puts "promise-diff: not a commit: #{r}"
    exit 0
  end
end

puts "promise-diff #{from}..#{to}"
puts

breaks = []
adds = []
notes = []

moved, new_pins, dropped_pins, extended_pins = pinned_answers(from, to)
moved.each { |p| breaks << ["pinned answer changed", p] }
dropped_pins.each { |p| breaks << ["pinned answer withdrawn", p] }
new_pins.each { |p| adds << ["answer newly pinned", p] }
extended_pins.each { |p| adds << ["answers appended to", p] }

regressed, withdrawn, gained = rubyspec(from, to)
regressed.each { |f, n, s| breaks << ["rubyspec PASS lost (now #{s})", "#{f}: #{n}"] }
withdrawn.each { |f, n, _| notes << ["rubyspec PASS withdrawn by design", "#{f}: #{n}"] }
gained.each { |f, n| adds << ["rubyspec PASS gained", "#{f}: #{n}"] }

lim_added, lim_removed, lim_moved = limitations(from, to)
lim_added.each { |k, s| notes << ["limitation stated [#{s}]", k] }
lim_removed.each { |k, s| notes << ["limitation dropped [#{s}]", k] }
lim_moved.each { |k, a, b| notes << ["limitation reclassified [#{a} -> #{b}]", k] }

mk_a = manifest_keys(from)
mk_b = manifest_keys(to)
(mk_a - mk_b).each { |k| breaks << ["manifest field no longer read", k] }
(mk_b - mk_a).each { |k| adds << ["manifest field read", k] }

fl_a = compiler_flags(from)
fl_b = compiler_flags(to)
(fl_a - fl_b).each { |f| breaks << ["compiler flag removed", f] }
(fl_b - fl_a).each { |f| adds << ["compiler flag added", f] }

def section(title, rows)
  return if rows.empty?
  puts "#{title} (#{rows.length})"
  rows.sort_by { |r| [r[0], r[1]] }.each { |kind, what| puts "  #{kind}: #{what}" }
  puts
end

section("BREAKS -- something that was promised is not any more", breaks)
section("DELIBERATE -- a promise moved on purpose; check it was meant", notes)
section("ADDITIONS -- new promises, safe to make", adds)

if breaks.empty? && notes.empty? && adds.empty?
  puts "nothing in the promise surface moved."
else
  puts "#{breaks.length} break(s), #{notes.length} deliberate, #{adds.length} addition(s)."
end
puts
puts "Not covered: a promise nobody wrote down. Those arrive as bug reports;"
puts "writing one down is what puts it in this report from then on."
