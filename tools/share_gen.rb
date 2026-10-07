# Generated String-sharing probes (see tools/share_probe.rb).
#
#   ruby tools/share_gen.rb [--strength T | --random N] [--seed S]
#                           [--only F=L,..] [--id ID]
#
# A case is one row of FACTORS: what holds a mutable String first, the
# route that carries it to a second name, the mutation made through one of
# the two names, the read that observes them, how the String was made, and
# whether spinel compiles the program with --share-strings.
#
# In CRuby every name a String reaches holds the same object, so a mutation
# through one name is seen through every other. Spinel copies a String by
# default and refuses the programs whose answer a copy would change; under
# --share-strings (#6765) a String the share facts share is held as one
# `sp_String *` handle by every holder. Its answer is wrong wherever some
# value route between two holders passes a copy instead of the handle: the
# mutation through one name is then lost to the other, without a word.
# Such routes were found one at a time by hand (`then`, `tap`, a `begin`
# value, `+s`, `String(s)`, a method value through `map` or `Thread#value`,
# `catch`/`throw`, an exception's message, `Array.new(n, s)` ...), so the
# probe crosses every route with every holder, and each mutation and read
# with both. The copying routes (`dup`, `clone`, `String.new`, and `+s` of a
# frozen String) are routes too: there the second name must NOT see the
# mutation, and a route that hands over the handle where CRuby copies is
# wrong the other way.
#
# Each case is a class of its own (`SP<id>`, with the helper classes and
# methods its route needs; every method, variable, attribute and member
# name it defines outside a method body carries its id, so the cases of one
# program share no name the analysis joins on). Its `run` puts the String
# in its holder, carries it to a local `t`, prints the observer's read of
# both names, mutates one of them (printing `ok` or the class of what the
# mutation raised: a frozen String raises FrozenError through both), prints
# the observer again, then `p` of both names, and for `force_encoding`
# their encodings. The source name is read again through its holder each
# time (`a[0]`, `o.v<id>`, `@@s<id>`), so an element or a member that lost
# the handle shows as well as the local. A difference is named by the role
# of the line that differs: the last `p` when it does (`value: value@1` is
# a mutation through the holder the second name did not see), else the
# first line that differs.
#
# Every row is also compiled in the other mode (share_probe.rb runs each
# case with and without --share-strings), so a finding's `mode` says whether
# the answer is wrong under the flag, without it, or both.

require "prism"
require_relative "probe_common"

module ShareGen
  FACTORS = [
    # What holds the String first: a local, an instance, class or global
    # variable, a constant, an Array element, a Hash value, a Struct
    # member, a block's or a method's parameter, a local a lambda captures
    # (the rest of the case runs in the lambda), an attr_accessor.
    [:holder, %w[local ivar cvar global const arr_elem hash_val struct_member block_param method_param capture
                 attr]],
    # The route from the holder's read to the second name `t`. Method
    # values: a return (implicit, explicit, conditional, from a rescue
    # arm), a `begin` value, a yield's value, a block's value through then,
    # tap, map, inject, each_with_object, find, max_by and sort_by, a
    # `break` out of `loop` and `while`, catch/throw, Thread#value,
    # Fiber#resume, Method#call, Proc#call, super, send, public_send and a
    # call on a receiver of two classes (poly). Conversions that answer
    # their receiver: `+s`, String(s), itself, clamp. Bindings: `||=`, a
    # multiple assignment, a splat, a keyword and a default argument, a
    # pattern. Containers stored and read back: an element, Hash#fetch,
    # dig and a default, Struct#to_a, Array.new(n, s), `[s] * 2`, an
    # exception's message, instance_variable_get. Copies: dup, clone,
    # String.new.
    [:route, %w[assign ret_implicit ret_explicit ret_cond ret_rescue begin_val yield_val then tap map inject
                each_with_object find max_by sort_by loop_break while_break catch_throw thread_value fiber_resume
                method_call proc_call super send public_send poly uplus string_conv itself or_asgn masgn splat
                kwarg default_arg elem_store hash_fetch hash_dig hash_default struct_to_a pattern array_new
                array_mul clamp exc_message ivar_get dup clone str_new]],
    [:mutation, %w[append concat replace insert aset setbyte upcase gsub sub squeeze clear force_encoding prepend]],
    # dst mutates the second name and observes the holder; src the reverse
    [:through, %w[dst src]],
    # The read before and after the mutation: `p` of both names, equal?,
    # object_id ==, frozen? and size of each.
    [:observer, %w[p equal object_id frozen size]],
    # How the String is made: `+"aabc"`, an interpolation (`"aab#{n}"`), or
    # a frozen literal, which every mutation refuses with FrozenError and a
    # copying route answers unfrozen.
    [:origin, %w[plus_lit interp frozen]],
    # share: compiled with --share-strings; plain: without
    [:mode, %w[share plain]],
  ].freeze
  NAMES = FACTORS.map(&:first).freeze
  # The first level of each factor is its simplest; reducing a case walks
  # factors toward it.
  SIMPLEST = FACTORS.to_h { |f, l| [f, l[0]] }.freeze
  # The factor the summary counts each label under (probe_common.rb).
  SPLIT = :mode
  # The refusals of a String the compiler cannot share yet, which name the
  # route and say neither "unsupported" nor "is not supported": without the
  # flag, a route that would copy ("(a String is not yet shared by reference
  # through ...)"), and under it, a holder that cannot be the handle.
  REFUSAL = /^spinel: .*(?:is not yet shared by reference|under --share-strings, the Strings? )/

  MUTATIONS = {
    "append" => "%s << \"x\"", "concat" => "%s.concat(\"y\")", "replace" => "%s.replace(\"zz\")",
    "insert" => "%s.insert(0, \"w\")", "aset" => "%s[0] = \"Q\"", "setbyte" => "%s.setbyte(0, 65)",
    "upcase" => "%s.upcase!", "gsub" => "%s.gsub!(\"a\", \"o\")", "sub" => "%s.sub!(\"b\", \"d\")",
    "squeeze" => "%s.squeeze!", "clear" => "%s.clear", "force_encoding" => "%s.force_encoding(\"ASCII-8BIT\")",
    "prepend" => "%s.prepend(\"p\")"
  }.freeze

  # A case whose realized levels do not render back to it: a bug here, not
  # in the compiler under test.
  class GeneratorError < StandardError; end

  extend ProbeCommon::Covering
  Case = ProbeCommon::Covering::Case

  # The I-th of N slices of the rows (share_probe.rb's --shard), or nil.
  class << self
    attr_accessor :shard
  end

  # Every row in both modes, the share mode first and the plain one next
  # to it, numbered again in that order (row k's cases are 2k+1 and 2k+2):
  # the covering array's rows, and those its pairs added. With mode pinned,
  # only that mode. A shard keeps every N-th row from the I-th on, under
  # the numbers of the whole run, so a case file names the same case in
  # every shard and run of one seed.
  def self.covering_cases(t, seed, tries = 100, only = {}, also = [])
    cases, *counts = super
    [both_modes(cases.map(&:realized), only), *counts]
  end

  def self.random_rows(n, seed)
    both_modes(super, {}).map(&:realized)
  end

  def self.both_modes(rows, only)
    modes = only[:mode] ? [only[:mode]] : FACTORS.to_h[:mode]
    rows = rows.map { |r| r.except(:mode) }.uniq
    keep = shard ? (0...rows.size).select { |k| k % shard[1] == shard[0] } : (0...rows.size).to_a
    keep.flat_map do |k|
      modes.each_with_index.map { |m, j| render(k * modes.size + j + 1, rows[k].merge(mode: m)) }
    end
  end

  module_function

  def indent(s, by)
    s.gsub(/^(?=.)/, by)
  end

  # The String's making expression.
  def origin_src(o)
    case o
    when "plus_lit" then "+\"aabc\""
    when "interp" then "\"aab\#{ARGV.size}\""
    when "frozen" then "\"aabc\""
    else raise GeneratorError, "no origin #{o}"
    end
  end

  # The holder of case `n` for a String made by `g`: [the class body's
  # lines, the lines that put the String in it, the expression that reads
  # it, how the rest of the case is placed (nil: after the setup)].
  def holder(h, n, g)
    case h
    when "local" then ["", "s = #{g}\n", "s", nil]
    when "ivar" then ["", "@s#{n} = #{g}\n", "@s#{n}", nil]
    when "cvar" then ["", "@@s#{n} = #{g}\n", "@@s#{n}", nil]
    when "global" then ["", "$sp#{n} = #{g}\n", "$sp#{n}", nil]
    when "const" then ["HS = #{g}\n", "", "HS", nil]
    when "arr_elem" then ["", "a = [#{g}]\n", "a[0]", nil]
    when "hash_val" then ["", "h = { k: #{g} }\n", "h[:k]", nil]
    when "struct_member" then ["St = Struct.new(:v#{n})\n", "o = St.new(#{g})\n", "o.v#{n}", nil]
    when "attr" then ["attr_accessor :v#{n}\n", "self.v#{n} = #{g}\n", "self.v#{n}", nil]
    when "block_param" then ["", "", "s", ->(rest) { "[#{g}].each do |s|\n#{indent(rest, "  ")}end\n" }]
    when "capture" then ["", "", "s", ->(rest) { "s = #{g}\nf = lambda do\n#{indent(rest, "  ")}end\nf.call\n" }]
    when "method_param" then ["", "", "s", :method]
    else raise GeneratorError, "no holder #{h}"
    end
  end

  # The route of case `n` from the read `s`: [the class's helper methods
  # and constants, the classes it needs ahead of the case's own (and the
  # superclass of the case's), the lines that end with the second name `t`
  # bound].
  def route(r, n, s)
    m = "r#{n}"
    id = "def #{m}(x) = x\n"
    case r
    when "assign" then ["", nil, "t = #{s}\n"]
    when "ret_implicit" then [id, nil, "t = #{m}(#{s})\n"]
    when "ret_explicit" then ["def #{m}(x)\n  return x\nend\n", nil, "t = #{m}(#{s})\n"]
    when "ret_cond" then ["def #{m}(x) = ARGV.empty? ? x : nil\n", nil, "t = #{m}(#{s})\n"]
    when "ret_rescue" then ["def #{m}(x)\n  raise \"e\"\nrescue\n  x\nend\n", nil, "t = #{m}(#{s})\n"]
    when "begin_val" then ["", nil, "t = begin\n  #{s}\nrescue\n  nil\nend\n"]
    when "yield_val" then ["def #{m} = yield\n", nil, "t = #{m} { #{s} }\n"]
    when "then" then ["", nil, "t = #{s}.then { |v| v }\n"]
    when "tap" then ["", nil, "t = #{s}.tap { |v| v }\n"]
    when "map" then ["", nil, "t = [#{s}].map { |v| v }[0]\n"]
    when "inject" then ["", nil, "t = [1].inject(#{s}) { |m, _v| m }\n"]
    when "each_with_object" then ["", nil, "t = [1].each_with_object(#{s}) { |_v, m| m }\n"]
    when "find" then ["", nil, "t = [#{s}].find { |v| v }\n"]
    when "max_by" then ["", nil, "t = [#{s}].max_by { |v| v.size }\n"]
    when "sort_by" then ["", nil, "t = [#{s}].sort_by { |v| v.size }[0]\n"]
    when "loop_break" then ["", nil, "t = loop do\n  break #{s}\nend\n"]
    when "while_break" then ["", nil, "t = while true\n  break #{s}\nend\n"]
    when "catch_throw" then ["", nil, "t = catch(:k) do\n  throw :k, #{s}\nend\n"]
    when "thread_value" then ["", nil, "t = Thread.new { #{s} }.value\n"]
    when "fiber_resume" then ["", nil, "t = Fiber.new { #{s} }.resume\n"]
    when "method_call" then [id, nil, "t = method(:#{m}).call(#{s})\n"]
    when "proc_call" then ["", nil, "t = proc { |v| v }.call(#{s})\n"]
    when "super"
      ["def #{m}(x) = super\n", ["class SP#{n}B\n  def #{m}(x) = x\nend\n", "SP#{n}B"], "t = #{m}(#{s})\n"]
    when "send" then [id, nil, "t = send(:#{m}, #{s})\n"]
    when "public_send" then [id, nil, "t = public_send(:#{m}, #{s})\n"]
    when "poly"
      ["", ["class SP#{n}P\n  def #{m}(x) = x\nend\n\nclass SP#{n}Q\n  def #{m}(x) = x\nend\n", nil],
       "o2 = ARGV.empty? ? SP#{n}P.new : SP#{n}Q.new\nt = o2.#{m}(#{s})\n"]
    when "uplus" then ["", nil, "t = +#{s}\n"]
    when "string_conv" then ["", nil, "t = String(#{s})\n"]
    when "itself" then ["", nil, "t = #{s}.itself\n"]
    when "or_asgn" then ["", nil, "t = nil\nt ||= #{s}\n"]
    when "masgn" then ["", nil, "t, _u = #{s}, 1\n"]
    when "splat" then ["def #{m}(*x) = x[0]\n", nil, "t = #{m}(*[#{s}])\n"]
    when "kwarg" then ["def #{m}(v:) = v\n", nil, "t = #{m}(v: #{s})\n"]
    when "default_arg" then ["", nil, "d = ->(v = #{s}) { v }\nt = d.call\n"]
    when "elem_store" then ["", nil, "b = [nil]\nb[0] = #{s}\nt = b[0]\n"]
    when "hash_fetch" then ["", nil, "h2 = { k: #{s} }\nt = h2.fetch(:k)\n"]
    when "hash_dig" then ["", nil, "h2 = { k: [#{s}] }\nt = h2.dig(:k, 0)\n"]
    when "hash_default" then ["", nil, "h2 = Hash.new(#{s})\nt = h2[:none]\n"]
    when "struct_to_a" then ["Sw = Struct.new(:w)\n", nil, "t = Sw.new(#{s}).to_a[0]\n"]
    when "pattern" then ["", nil, "case [#{s}]\nin [t]\nend\n"]
    when "array_new" then ["", nil, "t = Array.new(2, #{s})[1]\n"]
    when "array_mul" then ["", nil, "t = ([#{s}] * 2)[1]\n"]
    when "clamp" then ["", nil, "t = #{s}.clamp(\"a\", \"z\")\n"]
    when "exc_message"
      ["", nil, "t = begin\n  raise #{s}\nrescue => e\n  e.message\nend\n"]
    when "ivar_get" then ["", nil, "@tmp#{n} = #{s}\nt = instance_variable_get(:@tmp#{n})\n"]
    when "dup" then ["", nil, "t = #{s}.dup\n"]
    when "clone" then ["", nil, "t = #{s}.clone\n"]
    when "str_new" then ["", nil, "t = String.new(#{s})\n"]
    else raise GeneratorError, "no route #{r}"
    end
  end

  # One line of the observer's read of the holder's name `a` and the
  # second name `b`.
  def observe(o, n, a, b)
    case o
    when "p" then "print \"#{n} \"\np([#{a}, #{b}])\n"
    when "equal" then "puts \"#{n} \" + #{a}.equal?(#{b}).to_s\n"
    when "object_id" then "puts \"#{n} \" + (#{a}.object_id == #{b}.object_id).to_s\n"
    when "frozen" then "puts \"#{n} \" + #{a}.frozen?.to_s + \" \" + #{b}.frozen?.to_s\n"
    when "size" then "puts \"#{n} \" + #{a}.size.to_s + \" \" + #{b}.size.to_s\n"
    else raise GeneratorError, "no observer #{o}"
    end
  end

  # The program of `row` and the levels it realizes. Every row realizes
  # as it is: each holder takes each route, mutation and read.
  def build(n, row)
    g = origin_src(row[:origin])
    hdefs, setup, s, place = holder(row[:holder], n, g)
    rdefs, pre, bind = route(row[:route], n, s)
    mutated = row[:through] == "dst" ? "t" : s
    body = +bind
    body << observe(row[:observer], n, s, "t")
    body << "begin\n  #{format(MUTATIONS.fetch(row[:mutation]), mutated)}\n  puts \"#{n} ok\"\n" \
            "rescue => e\n  puts \"#{n} \" + e.class.to_s\nend\n"
    body << observe(row[:observer], n, s, "t")
    body << "print \"#{n} \"\np([#{s}, t])\n"
    if row[:mutation] == "force_encoding"
      body << "puts \"#{n} \" + #{s}.encoding.to_s + \" \" + t.encoding.to_s\n"
    end
    defs = hdefs + rdefs
    run = case place
          when nil then setup + body
          when :method
            defs += "def body#{n}(s)\n#{indent(body, "  ")}end\n"
            "body#{n}(#{g})\n"
          else place.call(body)
          end
    klass, sup = pre
    src = +""
    src << klass << "\n" if klass
    src << "class SP#{n}#{sup ? " < #{sup}" : ""}\n"
    src << indent(defs, "  ") << "\n" unless defs.empty?
    src << "  def run\n#{indent(run, "    ")}  end\nend\n\nSP#{n}.new.run\n"
    [src, row.dup]
  end

  # The case of `row`, numbered `id`. Its realized levels must render back
  # to the same program: a reduction steps from them, and a case file names
  # them.
  def render(id, row)
    src, real = build(id, row)
    again, = build(id, real)
    raise GeneratorError, "case #{id} does not render back from its realized levels" unless again == src
    Case.new(id, real, src)
  end

  # The flags spinel compiles `cases` with: one program is one mode.
  def flags(cases)
    modes = cases.map { |c| c.realized[:mode] }.uniq
    raise GeneratorError, "the cases of one program take one mode" unless modes.size == 1
    modes[0] == "share" ? ["--share-strings"] : []
  end

  # The cases as one program, under CRuby's frozen string literals (the
  # oracle is `ruby --enable-frozen-string-literal`). The probe compiles one
  # mode to a program; the generator's own listing (`any_mode`) is the CRuby
  # program of them all, each case's mode in its shape.
  def program(cases, any_mode = false)
    fl = any_mode ? [] : flags(cases)
    src = "# frozen_string_literal: true\n" + (fl.empty? ? "" : "# spinel #{fl.join(" ")}\n") +
          cases.map { |c| "# case #{c.id}: #{shape(c)}\n" + c.src }.join("\n")
    raise GeneratorError, "a generated program does not parse" unless Prism.parse(src).errors.empty?
    src
  end

  # The roles of a case's lines, in the order it prints them.
  def roles(real)
    %w[before mutation after value] + (real[:mutation] == "force_encoding" ? %w[encoding] : [])
  end

  # What kind of difference spinel's lines `got` are from CRuby's `want` in
  # case `c`: the role of the line that differs, and how it differs. The
  # `value` line (`p` of both names after the mutation) comes first when it
  # differs: it says which name lost the mutation (`value@0` the holder,
  # `value@1` the second name) whatever the observer, so a reduction steps
  # the observer to `p`. Else the first line that differs.
  def diff_kind(want, got, c)
    if (k = ProbeCommon.count_kind(want, got))
      return k
    end
    v = roles(c.realized).index("value")
    at = ([v] + (0...want.size).to_a).find { |i| !ProbeCommon.same_answer?(want[i], got[i]) }
    return "exit-status" if at.nil?
    "#{roles(c.realized)[at]}: #{ProbeCommon.answer_kind(want[at], got[at], "value")}"
  end
end

if $PROGRAM_NAME == __FILE__
  strength = 2
  random = nil
  seed = 1
  id = nil
  only = {}
  args = ARGV.dup
  begin
    until args.empty?
      case args.shift
      when "--strength" then strength = Integer(args.shift)
      when "--random" then random = Integer(args.shift)
      when "--seed" then seed = Integer(args.shift)
      when "--id" then id = Integer(args.shift)
      when "--only" then only.merge!(ShareGen.pins(args.shift.to_s))
      else raise ArgumentError
      end
    end
    raise ArgumentError unless (1..ShareGen::FACTORS.size).cover?(strength) && (random.nil? || random.positive?)
  rescue ArgumentError, TypeError => e
    warn e.message unless e.message == "ArgumentError"
    abort "usage: ruby tools/share_gen.rb [--strength T | --random N] [--seed S] [--only F=L,..] [--id ID]"
  end
  if random
    cs = ShareGen.pinned_cases(ShareGen.random_rows(random, seed), only)
    warn "#{cs.size} cases"
  else
    cs, want, got = ShareGen.covering_cases(strength, seed, 100, only)
    warn "#{cs.size} cases, taking #{got} of #{want} #{strength}-way combinations"
  end
  cs = cs.select { |c| c.id == id } if id
  print ShareGen.program(cs, true)
end
