#!/usr/bin/env ruby
# frozen_string_literal: true
# route_audit.rb -- every target of a call goes through the call plan.
#
#   tools/route_audit.rb [--staged | --rev REV] [FILE...]
#
# call_target (call_plan.c) is the one place a site asks which method a
# call runs, so that a call bound to one of a method's versions (#9898) is
# bound everywhere. In the files tools/route_audit.allow lists under
# `files:`, a by-name lookup of the tables (comp_method_in_chain and kin)
# passes when its name is a string literal (a method the language calls by
# a fixed name) or when its function (or the function and that lookup) is
# listed there with the reason it asks about a name rather than one call
# (`=NAME` lists the lookups of that name argument only). Any other is a
# call target that bypasses call_target, and so is a lookup taken as a
# value (`(cm ? comp_cmethod_in_class : comp_method_in_class)(c, k, nm)`,
# `{ comp_method_in_class }`).
# With FILEs, only those of them the list names are read (gate.rb passes a
# commit's changed sources).
#
# The sources and the list are read from the working tree, from the index
# with --staged (the pre-commit check), or from revision REV with --rev (a
# range check), so the change judged is the one read.
#
# Exit status: 0 clean, 1 a lookup to route or list.
ROOT = File.expand_path("..", __dir__)
LOOKUP = /\b(comp_method_in_chain|comp_cmethod_in_chain|comp_method_in_class|comp_cmethod_in_class|comp_method_index|comp_name_responders)\s*\(/
NAME_ARG = { "comp_method_index" => 1, "comp_name_responders" => 1 }.freeze
AS_VALUE = /\b(comp_method_in_chain|comp_cmethod_in_chain|comp_method_in_class|comp_cmethod_in_class|comp_method_index|comp_name_responders)\b(?=\s*[:;),}])/
C_KEYWORD = %w[if else while for switch return sizeof do case].freeze

blob = nil   # the git blob prefix (":" the index, "REV:" a revision), or the working tree
case ARGV.first
when "--staged" then ARGV.shift; blob = ":"
when "--rev" then ARGV.shift; blob = "#{ARGV.shift or abort 'route-audit: --rev needs a revision'}:"
end

# the text of path in the selected source, or nil when it has none: its
# bytes, whatever the locale, as File.binread reads the working tree
read = lambda do |path|
  if blob
    out = IO.popen(["git", "-C", ROOT, "show", "#{blob}#{path}"], err: File::NULL, binmode: true, &:read)
    $?.success? ? out : nil
  else
    full = File.join(ROOT, path)
    File.exist?(full) ? File.binread(full) : nil
  end
end

allow = {}
files = []
list = read.("tools/route_audit.allow") or abort "route-audit: tools/route_audit.allow is not in the source read"
list.each_line do |l|
  l = l.sub(/#.*/, "").strip
  next if l.empty?
  if l.start_with?("files:") then files.concat(l.split[1..])
  else
    f, fn, look, = l.split(/\s+/, 4)
    allow[look&.start_with?("comp_", "=") ? "#{f} #{fn} #{look}" : "#{f} #{fn}"] = true
  end
end
files &= ARGV.map { |a| a.delete_prefix("#{ROOT}/") } unless ARGV.empty?

# the C text with its comments blanked (newlines kept, so offsets and line
# numbers stay), string and character literals left as they are
COMMENT_OR_LITERAL = %r{"(?:\\.|[^"\\\n])*"|'(?:\\.|[^'\\\n])*'|/\*.*?(?:\*/|\z)|//[^\n]*}m
def code_of(src)
  src.gsub(COMMENT_OR_LITERAL) { |t| t.start_with?("/") ? t.gsub(/[^\n]/, " ") : t }
end

# the arguments of the call whose "(" ends at index i of text s, across lines
def args(s, i)
  depth = 1
  out = +""
  parts = []
  quote = nil
  while i < s.size
    ch = s[i]
    if quote
      out << ch
      if ch == "\\" then out << s[i + 1].to_s; i += 1
      elsif ch == quote then quote = nil
      end
    elsif ch == '"' || ch == "'"
      quote = ch
      out << ch
    else
      depth += 1 if ch == "("
      depth -= 1 if ch == ")"
      break if depth.zero?
      if ch == "," && depth == 1 then parts << out.strip; out = +"" else out << ch end
    end
    i += 1
  end
  parts << out.strip
end

bad = []
files.each do |f|
  src = read.(f) or next
  code = code_of(src.b)   # bytes: the walk below indexes the text
  # where each function starts: a line at column 0 naming one, not a
  # declaration, nor a statement written at column 0 ("else if (")
  starts = []
  off = 0
  code.each_line do |l|
    starts << [off, $1] if l =~ /\A[A-Za-z][^;=]*?\b(\w+)\s*\(/ && !l.rstrip.end_with?(";") && !C_KEYWORD.include?($1)
    off += l.size
  end
  function_at = ->(at) { starts.reverse_each.find { |o, _| o <= at }&.last }
  line_at = ->(at) { code[0, at].count("\n") + 1 }
  code.to_enum(:scan, LOOKUP).each do
    m = Regexp.last_match
    fn = function_at.(m.begin(0))
    next if m[1] == fn   # the lookup's own definition
    name = args(code, m.end(0))[NAME_ARG.fetch(m[1], 2)].to_s.gsub(/\s+/, " ")
    next if name.start_with?('"') || fn == "call_target"
    next if allow["#{f} #{fn}"] || allow["#{f} #{fn} #{m[1]}"] || allow["#{f} #{fn} =#{name}"]
    bad << "#{f}:#{line_at.(m.begin(0))}: #{fn}: #{m[1]}(..., #{name}, ...): a call's target goes through call_target, or list #{fn} in tools/route_audit.allow with why it asks about a name"
  end
  code.to_enum(:scan, AS_VALUE).each do
    m = Regexp.last_match
    fn = function_at.(m.begin(0))
    next if fn == "call_target" || allow["#{f} #{fn}"] || allow["#{f} #{fn} #{m[1]}"]
    bad << "#{f}:#{line_at.(m.begin(0))}: #{fn}: #{m[1]} taken as a value: a call's target goes through call_target, or list #{fn} in tools/route_audit.allow with why it asks about a name"
  end
end
bad.each { |b| warn "route-audit: #{b}" }
exit(bad.empty? ? 0 : 1)
