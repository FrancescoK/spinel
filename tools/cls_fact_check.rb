# Holds spinel's class facts (#8530) against a CRuby run of the same
# program. The facts come from `SPINEL_CLS_FACTS=1 spinel ... -c`, the
# observations from tools/cls_fact_trace.rb. A fact is a may-hold set: a
# receiver class CRuby saw at a call site must be in the site's set, or a
# consumer may drop the arm that call needs (#8720).
#
#   ruby tools/cls_fact_check.rb FACTS TRACE
#
# Prints one line per violation and exits 1 when there is any. Only a
# receiver whose class the program defines is checked (a builtin class is
# the set's +builtin); several calls of one name on one line are held
# against the union of their sets. A call that reached one of CRuby's own
# Ruby-defined methods (`<internal:...>`) is marked [builtin]: no dispatch
# arm is lost there, but the fact is still wrong. A line with a send
# (`send`, `public_send`, `__send__`) is skipped: the method it reaches is
# not the call the fact is about.
require "set"

facts_path, trace_path = ARGV
facts = Hash.new { |h, k| h[k] = Set.new }
files = Set.new
sends = Set.new
File.foreach(facts_path) do |l|
  next unless l.start_with?("cls-fact: ")
  m = l.chomp.match(/\Acls-fact: (.*):(\d+) (\S+) receiver:(.*)\z/) or next
  path = File.expand_path(m[1])
  files << path
  facts[[path, m[2].to_i, m[3]]].merge(m[4].split(" "))
  sends << [path, m[2].to_i] if %w[send public_send __send__].include?(m[3])
end

bad = []
File.foreach(trace_path) do |l|
  path, line, meth, recv, src, callee = l.chomp.split("\t", -1)
  set = facts[[path, line.to_i, meth]] if facts.key?([path, line.to_i, meth])
  next unless set
  next if sends.include?([path, line.to_i])
  next if set.include?("ANY") || set.include?(recv)
  # a class defined by its path (`class A::B::C`) is named by its leaf
  # (or by a name qualify_colliding_classes joined with __)
  leaf = ->(n) { n.gsub("__", "::").sub(/\AClass\((.*)\)\z/) { "Class(#{$1.split('::').last})" }.split("::").last }
  next if set.any? { |e| leaf.(e) == leaf.(recv) }
  next if src.nil? || src.empty? || !files.include?(File.expand_path(src))
  tag = callee.to_s.start_with?("<internal:") ? " [builtin]" : ""
  bad << "#{path}:#{line} #{meth}: receiver #{recv} not in {#{set.to_a.sort.join(' ')}}#{tag}"
end
bad.uniq.each { |b| puts b }
exit(bad.empty? ? 0 : 1)
