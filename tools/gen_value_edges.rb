#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate the uniform arms of the value-position iterator (src/value_pos.c)
# from tools/value_edges.yml, the annotation of which child of each Prism
# node carries the node's own value.
#
#   ruby tools/gen_value_edges.rb            # print the arms
#   ruby tools/gen_value_edges.rb --write    # regenerate src/value_pos_arms.inc
#   ruby tools/gen_value_edges.rb --check    # fail when the annotation and
#                                            # Prism's config.yml disagree, the
#                                            # generated file is stale, or a
#                                            # hand-written arm is missing
#                                            # (make value-edges-check)
#
# The generated file is checked in, so a build needs no Ruby (the way
# src/builtin_arity.inc is). --check reads the pinned Prism gem's
# vendor/prism/config.yml (PRISM_CONFIG names another), which `make deps`
# fetches and the repository does not keep; run it after a PRISM_VERSION bump
# or a change to the annotation.
#
# What it emits: one `case NK_<kind>:` per entry whose role is `wrapper` or
# `branch` (see the head of the annotation). The `hand` entries are written
# in value_pos.c; --check demands a `case NK_<kind>:` there for each.

require "yaml"
require "optparse"

ROOT = File.expand_path("..", __dir__)
EDGES = File.join(ROOT, "tools/value_edges.yml")
CONFIG = ENV["PRISM_CONFIG"] || File.join(ROOT, "vendor/prism/config.yml")
OUTPUT = File.join(ROOT, "src/value_pos_arms.inc")
ITERATOR = File.join(ROOT, "src/value_pos.c")

ROLES = %w[wrapper branch hand].freeze
GATES = %w[IF UNLESS CASE CASE_IN BEGIN_PLAIN BEGIN_CLAUSES RESCUE_MOD LOGIC].freeze

# A field as the annotation spells it: `f`, `f.*` (every element of a list),
# `f.last` (the last element) or `f.*.g` (the field g of every element); a
# trailing `?` says that an absent node is no position at all (a missing rescue
# successor re-raises), where otherwise it is a nil.
Field = Struct.new(:name, :mode, :sub, :opt) do
  def list? = mode != :one
end

def parse_field(text)
  opt = text.end_with?("?")
  field = parse_spelling(text.delete_suffix("?"))
  field.opt = opt
  field
end

def parse_spelling(text)
  case text
  when /\A(\w+)\.\*\z/ then Field.new($1, :all)
  when /\A(\w+)\.\*\.(\w+)\z/ then Field.new($1, :arms, $2)
  when /\A(\w+)\.last\z/ then Field.new($1, :last)
  when /\A(\w+)\z/ then Field.new($1, :one)
  else abort "#{EDGES}: bad field spelling #{text.inspect}"
  end
end

def load_edges
  y = YAML.safe_load_file(EDGES)
  abort "#{EDGES}: no `nodes` map" unless y.is_a?(Hash) && y["nodes"].is_a?(Hash)
  nodes = y["nodes"].transform_values do |e|
    role = e["role"]
    abort "#{EDGES}: unknown role #{role.inspect}" if role && !ROLES.include?(role)
    abort "#{EDGES}: unknown gate #{e["gate"].inspect}" if e["gate"] && !GATES.include?(e["gate"])
    { role: role, gate: e["gate"], link: e["link"],
      value: (e["value"] || []).map { |t| parse_field(t) },
      skip: (e["skip"] || []).map { |t| parse_field(t) } }
  end
  [nodes, y["childless"] || []]
end

# ---- the arms ----

# The arm of field `idx`: how many value positions precede it, a list's
# length counted at run time, from the chain's base arm when the node has one.
def slot_expr(fields, idx, chained)
  terms = chained ? ["base"] : []
  fixed = 0
  fields[0...idx].each_with_index do |f, i|
    f.mode == :one ? fixed += 1 : terms << "an#{i}"
  end
  terms << fixed.to_s if fixed > 0
  terms.empty? ? "0" : terms.join(" + ")
end

def gen_wrapper(name, e)
  f = e[:value].first
  abort "#{name}: a wrapper has exactly one value field" unless e[:value].size == 1
  out = +"  case NK_#{name}: {\n"
  out << "    if (!(w->shapes & VPS_#{e[:gate]})) break;\n" if e[:gate]
  if f.mode == :one
    out << "    cur->node = nt_ref(nt, cur->node, \"#{f.name}\");\n"
  else
    abort "#{name}: a wrapper takes the last element of a list" unless f.mode == :last
    out << "    int an = 0;\n"
    out << "    const int *av = nt_arr(nt, cur->node, \"#{f.name}\", &an);\n"
    out << "    cur->node = an > 0 ? av[an - 1] : -1;\n"
  end
  out << "    cur->link = 0;\n"
  out << "    return VPSTEP_PEEL;\n"
  out << "  }\n"
end

def gen_branch(name, e)
  fields = e[:value]
  out = +"  case NK_#{name}: {\n"
  out << "    if (!(w->shapes & VPS_#{e[:gate]})) break;\n" if e[:gate]
  out << "    int n = cur->node;\n"
  out << "    int #{e[:link] ? "base = cur->link ? cur->arm : 0, " : ""}d = cur->depth + 1;\n"
  fields.each_with_index do |f, i|
    next if f.mode == :one
    abort "#{name}: a branch walks every element of a list" unless %i[all arms].include?(f.mode)
    out << "    int an#{i} = 0;\n"
    out << "    const int *av#{i} = nt_arr(nt, n, \"#{f.name}\", &an#{i});\n"
  end
  # pushed last field first, so the first pops first: source order
  fields.each_with_index.reverse_each do |f, i|
    slot = slot_expr(fields, i, !e[:link].nil?)
    if f.mode == :one
      link = f.name == e[:link] ? 1 : 0
      if f.opt
        out << "    int #{f.name}_at = nt_ref(nt, n, \"#{f.name}\");\n"
        out << "    if (#{f.name}_at >= 0) vp_push(w, #{f.name}_at, n, #{slot}, d, #{link});\n"
      else
        out << "    vp_push(w, nt_ref(nt, n, \"#{f.name}\"), n, #{slot}, d, #{link});\n"
      end
    else
      elem = f.mode == :arms ? "nt_ref(nt, av#{i}[i], \"#{f.sub}\")" : "av#{i}[i]"
      out << "    for (int i = an#{i} - 1; i >= 0; i--) vp_push(w, #{elem}, n, #{slot == "0" ? "i" : "#{slot} + i"}, d, 0);\n"
    end
  end
  out << "    return VPSTEP_EXPANDED;\n"
  out << "  }\n"
end

def generate(nodes)
  out = +"/* Generated by tools/gen_value_edges.rb from tools/value_edges.yml; do not edit.\n"
  out << "   The arms of vp_step's switch (src/value_pos.c) for the nodes whose value\n"
  out << "   positions are a fixed list of fields: a `wrapper` is looked through, a\n"
  out << "   `branch` is a parent of its fields. A gate is the shape bit that has to be\n"
  out << "   on; with it off the node is a leaf (the break leaves the switch). */\n"
  nodes.sort_by { |name, _| name }.each do |name, e|
    case e[:role]
    when "wrapper" then out << gen_wrapper(name, e)
    when "branch" then out << gen_branch(name, e)
    end
  end
  out
end

# ---- the check against Prism ----

# The child fields of every node in config.yml: name => { list:, kinds: } (the
# kinds a field allows, error-recovery ones left out; empty for any node).
def prism_children(config)
  config["nodes"].to_h do |n|
    fields = (n["fields"] || []).filter_map do |f|
      next unless %w[node node? node[]].include?(f["type"])
      kinds = Array(f["kind"]).grep(String)
      [f["name"], { list: f["type"] == "node[]", kinds: kinds }]
    end
    [n["name"], fields.to_h]
  end
end

def check(nodes, childless)
  abort "#{CONFIG} is missing: run `make deps` (it fetches the pinned Prism gem)" unless File.exist?(CONFIG)
  prism = prism_children(YAML.load_file(CONFIG))
  errors = []
  prism.each do |kind, fields|
    if fields.empty?
      errors << "#{kind}: has no child field, but is not listed under `childless`" unless childless.include?(kind) || nodes.key?(kind)
      errors << "#{kind}: listed under `childless` and under `nodes`" if childless.include?(kind) && nodes.key?(kind)
      next
    end
    e = nodes[kind]
    unless e
      errors << "#{kind}: not annotated (child fields: #{fields.keys.join(", ")})"
      next
    end
    check_node(kind, e, fields, prism, errors)
  end
  nodes.each_key { |k| errors << "#{k}: annotated, but Prism has no such node" unless prism.key?(k) }
  childless.each do |k|
    errors << "#{k}: listed under `childless`, but Prism has no such node" unless prism.key?(k)
    errors << "#{k}: listed under `childless`, but has child fields #{prism[k].keys.join(", ")}" if prism[k] && !prism[k].empty?
  end
  errors
end

def check_field(kind, f, shape, prism, errors)
  if shape.nil?
    errors << "#{kind}.#{f.name}: annotated, but Prism has no such child field"
  elsif shape[:list] && !f.list?
    errors << "#{kind}.#{f.name}: a list in Prism; spell it `#{f.name}.*` or `#{f.name}.last`"
  elsif !shape[:list] && f.list?
    errors << "#{kind}.#{f.name}: a single node in Prism, not a list"
  elsif f.mode == :arms
    shape[:kinds].each do |ek|
      errors << "#{kind}.#{f.name}.*.#{f.sub}: #{ek} has no child field #{f.sub}" unless prism[ek]&.key?(f.sub)
    end
  end
end

def check_node(kind, e, fields, prism, errors)
  seen = {}
  (e[:value] + e[:skip]).each do |f|
    errors << "#{kind}.#{f.name}: annotated twice" if seen[f.name]
    seen[f.name] = true
    check_field(kind, f, fields[f.name], prism, errors)
  end
  (fields.keys - seen.keys).each { |n| errors << "#{kind}.#{n}: child field not annotated" }
  errors << "#{kind}: `value` is empty but role is #{e[:role]}" if e[:role] && e[:value].empty?
  errors << "#{kind}: has value fields but no role" if e[:role].nil? && !e[:value].empty?
  return unless e[:link]
  errors << "#{kind}: link #{e[:link]} is not a value field" if e[:value].none? { |f| f.name == e[:link] }
  errors << "#{kind}: link #{e[:link]} does not allow #{kind} itself" unless fields.dig(e[:link], :kinds)&.include?(kind)
end

# A hand entry stands for an arm in value_pos.c; the arms of the generated
# file are those of the file, so a stale copy would be silently a different
# iterator.
def check_hand(nodes)
  src = File.exist?(ITERATOR) ? File.read(ITERATOR) : ""
  nodes.select { |_, e| e[:role] == "hand" }.keys.filter_map do |k|
    "#{k}: role `hand`, but src/value_pos.c has no `case NK_#{k}:`" unless src.include?("case NK_#{k}:")
  end
end

opts = {}
OptionParser.new do |p|
  p.on("--write") { opts[:write] = true }
  p.on("--check") { opts[:check] = true }
end.parse!

nodes, childless = load_edges
text = generate(nodes)

if opts[:check]
  errors = check(nodes, childless) + check_hand(nodes)
  errors << "src/value_pos_arms.inc is stale; regenerate with --write" unless File.exist?(OUTPUT) && File.read(OUTPUT) == text
  if errors.empty?
    puts "value-edges-check: ok (#{nodes.size} annotated nodes, #{childless.size} childless)"
  else
    warn errors.map { |m| "value-edges-check: #{m}" }
    exit 1
  end
elsif opts[:write]
  File.write(OUTPUT, text)
  puts "wrote #{OUTPUT}"
else
  print text
end
