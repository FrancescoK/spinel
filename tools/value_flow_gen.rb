# Generated value-flow probes (see tools/value_flow_probe.rb).
#
#   ruby tools/value_flow_gen.rb [--strength T | --random N] [--seed S]
#                                [--only F=L,..] [--id ID]
#
# A case is one row of FACTORS: where a value that may be nil comes from, what
# carries it to the read, the operation that reads it, whether the slot it
# travels in holds an Integer, a Float, a Bool, a String or a Symbol, whether
# the object a carrier writes it into is frozen first, whether the case runs
# at the top level or in a method, and the mode the program is compiled in.
#
# Spinel keeps an Integer or a Float that may be nil in the slot's own type:
# the slot holds a sentinel for nil (SP_INT_NIL, a NaN payload for a Float),
# the analysis marks the variable (LocalVar.nullable_int), and a typed array
# marks the element it stores one in. Every read of such a slot has to ask for
# the sentinel before it takes the number, and every carrier that moves the
# value (a parameter, an ivar, an element, a Hash value, a poly handle) has to
# keep the marking, or a nil reads as a number, is boxed as one, or answers a
# type test as an Integer. These were fixed a read or a carrier at a time
# (#6026, #6112, #6138, #6140, #6142), each found by hand, so the probe crosses
# the three.
#
# A value also travels where no typed slot is: in an ivar only reflection
# writes, in a Struct's member (which is no ivar), in an object a splice or
# a fetch's block brings into an Array of other classes, or through a handle
# that may be another class (`[s, 0][0]`) into a setter of an object that may
# be frozen. Each of these took a bool, an object or a frozen check the
# wrong way in review (#6800, #6909), so the carriers take them too, and the
# Bool, String and Symbol types beside Integer and Float.
#
# Every carrier takes a present value of the slot's type first, which types
# the slot, then the source's value, so the nil lands in a typed slot. Each
# case prints the read's answer, or the class and message of what it raised,
# once for the present value, once for the source's, once more for a nil the
# carrier makes of its own (an Array's gap, a short each_slice row, the Array
# `map` answers), and, for an Array read (include?, join, sum, sort, <=>,
# pack ...) of a carrier that is an Array, once for that whole Array: a
# typed Array holding the sentinel is where #6112 and #6138 were. The first
# line that differs names the role of the value it read (`# lines:` above a
# case lists them).
#
# Some levels take another route where a carrier has no place for them: a
# missing splat element binds by the carrier's own binder only for a block or
# a proc (a lambda, a method and a constructor would raise ArgumentError), and
# elsewhere comes from a multiple assignment (`_, t = *[1]`); a nil default is
# the carrier's own optional parameter where it has one, and elsewhere a
# helper method's (`def od(z = nil) = z`), called with and without the value.
# Both are still the level they name, so every combination is taken.

require "prism"
require_relative "probe_common"

module ValueFlowGen
  FACTORS = [
    # nil_lit `nil`; arr_nil a nil stored in a typed array and read back
    # (`[1, nil][i]`); arr_oob an out-of-range read of a nil-free one
    # (`[1][i]`); computed `c ? nil : 1`; splat a missing splat element
    # (`yield(*[1])` into `|w, x|`); opt_default the nil default of an
    # optional parameter; present the value itself, a control. An index or a
    # condition is ARGV's, so no fold sees through it.
    [:source, %w[nil_lit arr_nil arr_oob computed splat opt_default present]],
    # method_obj is `method(:m).call`; arr_reader appends through an
    # attr_reader into an ivar's array (#6138's reader mutation); poly_or and
    # poly_cond read an element through a handle that is an Array or a String
    # (`s || arr`, `c ? arr : "s"`); captured is a local a lambda reads.
    # data a Data member; reflective_get and reflective_reader read, by
    # instance_variable_get or an attr_reader, an ivar instance_variable_set
    # wrote; struct_reflect asks instance_variable_get of a Struct, whose
    # member is no ivar, beside an object with that ivar; arr_splice,
    # arr_fetch and hash_fetch write an ivar of an object `a[0, 1] = [b]` or
    # a fetch's block brought in; setter, send_setter (`o.send(:x=, v)`),
    # struct_aset (`o[:x] = v`), ivset and ivset_struct
    # (instance_variable_set of a class's object or a Struct's) write
    # through a handle that may be another class.
    [:carrier, %w[local ivar global cvar block_param proc_param lambda_param method_obj method_param method_ret
                  reader alias_reader struct hash arr_push arr_lit arr_aset arr_gap arr_reader poly_or
                  poly_cond captured each_with_index map each_slice data reflective_get reflective_reader
                  struct_reflect arr_splice arr_fetch hash_fetch setter ivset ivset_struct struct_aset send_setter]],
    [:read, %w[value p inspect interp to_s nil_p eq_nil class_eqq is_a class case_nil case_class case_zero
               hash_key hash_aset hash_val include index count join sum max minmax sort cmp arr_cmp arr_cmp_nil
               pack to_a to_i and plus rplus gt or_asgn truthy array_conv string_conv number_conv splat_lit
               format zip product splat_call compact delete then]],
    [:type, %w[int float bool string symbol]],
    # frozen: the object a writing carrier writes into is frozen first, and
    # the write raises FrozenError
    [:frozen, %w[mutable frozen]],
    [:scope, %w[top method]],
    # promote: compiled with --int-overflow=promote, which boxes an Integer
    # slot another way
    [:mode, %w[default promote]],
  ].freeze
  NAMES = FACTORS.map(&:first).freeze
  # The first level of each factor is its simplest; reducing a case walks
  # factors toward it.
  SIMPLEST = FACTORS.to_h { |f, l| [f, l[0]] }.freeze
  # A type's present value, and the class a type test asks for. A Bool's is
  # false, the value a nil can pass for.
  VALUES = { "int" => "1", "float" => "1.5", "bool" => "false", "string" => '"value"',
             "symbol" => ":value" }.freeze
  CLASSES = { "int" => "Integer", "float" => "Float", "bool" => "FalseClass", "string" => "String",
              "symbol" => "Symbol" }.freeze
  # Carriers that write the value into an object, which can be frozen
  # first; elsewhere `frozen` realizes mutable. Those that write a Struct.
  WRITERS = %w[setter send_setter struct_aset ivset ivset_struct].freeze
  STRUCT_WRITERS = %w[send_setter struct_aset ivset_struct].freeze
  # Carriers whose value binds to a parameter a call can leave out (a nil
  # default) or a splat can leave short.
  OPTIONAL = %w[block_param proc_param lambda_param method_obj method_param reader alias_reader struct].freeze
  SPLATTED = %w[block_param proc_param].freeze
  # Reads of an Array holding the value: `[present, value]` for a scalar
  # carrier, and for a carrier that is an Array, also that Array itself.
  ARRAY_READS = %w[include index count join sum max minmax sort arr_cmp arr_cmp_nil pack zip product compact
                   delete].freeze
  ARRAYS = %w[arr_push arr_lit arr_aset arr_gap arr_reader poly_or poly_cond map].freeze

  # A case whose realized levels do not render back to it: a bug here, not in
  # the compiler under test.
  class GeneratorError < StandardError; end

  extend ProbeCommon::Covering
  Case = ProbeCommon::Covering::Case

  module_function

  # ---- a row as Ruby ----

  # The read `r` of `x` (an expression that reads the carrier and may be
  # followed by a call) in a slot of type `t` whose present value is `v`, in
  # case `n`: an expression, or nil for `p`, which prints its own line. An
  # Array read reads `arr` when given, else `[v, x]`.
  def read_src(r, x, t, v, n, arr = nil)
    k = CLASSES.fetch(t)
    a = arr || "[#{v}, #{x}]"
    case r
    when "value" then x
    when "p" then nil
    when "inspect" then "#{x}.inspect"
    when "interp" then "\"<\#{#{x}}>\""
    when "to_s" then "#{x}.to_s"
    when "nil_p" then "#{x}.nil?"
    when "eq_nil" then "(#{x} == nil)"
    when "class_eqq" then "(#{k} === #{x})"
    when "is_a" then "#{x}.is_a?(#{k})"
    when "class" then "#{x}.class"
    when "case_nil" then "(case #{x} when nil then :nil else :other end)"
    when "case_class" then "(case #{x} when #{k} then :num when nil then :nil else :other end)"
    when "case_zero" then "(case #{x} when 0 then :zero when nil then :nil else :other end)"
    when "hash_key" then "{ #{x} => 1 }"
    when "hash_aset" then "(hs#{n} = {}; hs#{n}[#{x}] = 1; hs#{n})"
    when "hash_val" then "{ k: #{x} }"
    when "include" then "#{a}.include?(nil)"
    when "index" then "#{a}.index(nil)"
    when "count" then "#{a}.count(nil)"
    when "join" then "#{a}.join(\"-\")"
    when "sum" then "#{a}.sum"
    when "max" then "#{a}.max"
    when "minmax" then "#{a}.minmax"
    when "sort" then "#{a}.sort"
    when "cmp" then "(#{x} <=> #{v})"
    # two Arrays alike, each holding the value (#6112 answered nil here)
    when "arr_cmp" then arr ? "(#{arr} <=> #{arr}.dup)" : "([#{v}, #{x}] <=> [#{v}, #{x}])"
    when "arr_cmp_nil" then "(#{a} <=> [#{v}, nil])"
    when "pack" then "#{a}.pack(\"#{t == "int" ? "q" : "d"}*\")"
    when "to_a" then "#{x}.to_a"
    when "to_i" then "#{x}.to_i"
    when "and" then "(#{x} & true)"
    when "plus" then "(#{x} + 1)"
    when "rplus" then "(#{v} + #{x})"
    when "gt" then "(#{x} > 0)"
    when "or_asgn" then "(oa#{n} = #{x}; oa#{n} ||= 7; oa#{n})"
    when "truthy" then "(#{x} ? :t : :f)"
    when "array_conv" then "Array(#{x})"
    when "string_conv" then "String(#{x})"
    when "number_conv" then "#{t == "float" ? "Float" : "Integer"}(#{x})"
    when "splat_lit" then "[*#{x}]"
    when "format" then "format(\"%p\", #{x})"
    when "zip" then "[#{v}, #{v}, #{v}].zip(#{a})"
    when "product" then "[#{v}].product(#{a})"
    when "splat_call" then "sc#{n}(*#{x})"
    when "compact" then "#{a}.compact"
    when "delete" then "(dl#{n} = #{a}; dl#{n}.delete(nil); dl#{n})"
    when "then" then "#{x}.then { |y#{n}| y#{n}.nil? }"
    else raise GeneratorError, "no read #{r}"
    end
  end

  # One answer line: `ID <answer>` or `ID <Class>: <message>`.
  def report(n, row, x, v, arr = nil)
    e = read_src(row[:read], x, row[:type], v, n, arr)
    say = e ? "puts \"#{n} \" + (#{e}).inspect" : "print \"#{n} \"\n  p(#{x})"
    "begin\n  #{say}\nrescue => e#{n}\n  puts \"#{n} \" + e#{n}.class.to_s + \": \" + e#{n}.message\nend\n"
  end

  def indent(s, by)
    s.gsub(/^(?=.)/, by)
  end

  # The program of `row` and the levels it realizes. Every name a case
  # defines carries its id, so the cases of one program share nothing the
  # compiler could type across them.
  def build(n, row)
    real = row.dup
    t = row[:type]
    v = VALUES.fetch(t)
    car = row[:carrier]
    real[:frozen] = "mutable" unless WRITERS.include?(car)
    src = row[:source]
    defs = +""
    # the present value and the source's, as expressions
    pv = v
    sv = case src
         when "nil_lit" then "nil"
         when "arr_nil" then "[#{v}, nil][ARGV.size + 1]"
         when "arr_oob" then "[#{v}][ARGV.size + 1]"
         when "computed" then "(ARGV.empty? ? nil : #{v})"
         when "present" then v
         when "splat" then "(sq#{n} = [#{v}]; _, st#{n} = *sq#{n}; st#{n})"
         when "opt_default"
           defs << "def od#{n}(z = nil) = z\n"
           pv = "od#{n}(#{v})"
           "od#{n}"
         end
    # a carrier with a parameter of its own leaves it out, or splats short
    own_opt = src == "opt_default" && OPTIONAL.include?(car)
    if own_opt
      defs.clear
      pv = v
    end
    own_splat = src == "splat" && SPLATTED.include?(car)
    xp = own_opt ? "x#{n} = nil" : "x#{n}"
    rep = ->(x) { report(n, row, x, v) }
    # an Array read of an Array carrier reads its whole Array too, last: a
    # delete changes it
    whole = ->(a) { ARRAY_READS.include?(row[:read]) ? report(n, row, "#{a}[1]", v, a) : "" }
    uses = +""
    case car
    when "local", "ivar", "global"
      x = { "local" => "x#{n}", "ivar" => "@x#{n}", "global" => "$x#{n}" }[car]
      uses << "#{x} = #{pv}\n" << rep.call(x) << "#{x} = #{sv}\n" << rep.call(x)
    when "cvar"
      defs << "class K#{n}\n  def self.a = (@@x = #{pv})\n  def self.b = (@@x = #{sv})\n\n" \
              "  def self.rd\n#{indent(rep.call("@@x"), "    ")}  end\nend\n"
      uses << "K#{n}.a\nK#{n}.rd\nK#{n}.b\nK#{n}.rd\n"
    when "block_param"
      last = if own_opt then "yield #{pv}"
             elsif own_splat then "sq#{n} = [#{pv}]\n  yield(*sq#{n})"
             else "yield #{pv}, #{sv}"
             end
      defs << "def y#{n}\n  yield #{pv}, #{pv}\n  #{last}\nend\n"
      uses << "y#{n} do |w#{n}, #{xp}|\n#{indent(rep.call("x#{n}"), "  ")}end\n"
    when "proc_param", "lambda_param"
      f = car == "proc_param" ? "proc do |w#{n}, #{xp}|" : "->(w#{n}, #{xp}) do"
      uses << "f#{n} = #{f}\n#{indent(rep.call("x#{n}"), "  ")}end\n"
      uses << "f#{n}.call(#{pv}, #{pv})\n"
      uses << if own_opt then "f#{n}.call(#{pv})\n"
              elsif own_splat then "sq#{n} = [#{pv}]\nf#{n}.call(*sq#{n})\n"
              else "f#{n}.call(#{pv}, #{sv})\n"
              end
    when "method_obj", "method_param"
      defs << "def m#{n}(w#{n}, #{xp})\n#{indent(rep.call("x#{n}"), "  ")}end\n"
      call = car == "method_obj" ? "q#{n}.call" : "m#{n}"
      uses << "q#{n} = method(:m#{n})\n" if car == "method_obj"
      uses << "#{call}(#{pv}, #{pv})\n" << (own_opt ? "#{call}(#{pv})\n" : "#{call}(#{pv}, #{sv})\n")
    when "method_ret"
      defs << "def g#{n}(k)\n  return #{pv} if k.zero?\n\n  #{sv}\nend\n"
      uses << rep.call("g#{n}(ARGV.size)") << rep.call("g#{n}(ARGV.size + 1)")
    when "reader", "alias_reader"
      name = car == "reader" ? "x" : "y"
      defs << "class A#{n}\n  attr_reader :x\n#{car == "alias_reader" ? "  alias y x\n" : ""}\n" \
              "  def initialize(#{own_opt ? "x = nil" : "x"}) = (@x = x)\nend\n"
      uses << rep.call("A#{n}.new(#{pv}).#{name}") << rep.call("A#{n}.new(#{own_opt ? "" : sv}).#{name}")
    when "struct"
      defs << "S#{n} = Struct.new(:x)\n"
      uses << rep.call("S#{n}.new(#{pv}).x") << rep.call("S#{n}.new(#{own_opt ? "" : sv}).x")
    when "data"
      defs << "D#{n} = Data.define(:x)\n"
      uses << rep.call("D#{n}.new(#{pv}).x") << rep.call("D#{n}.new(#{sv}).x")
    when "reflective_get", "reflective_reader"
      # an object whose ivar only instance_variable_set writes
      defs << "class A#{n}\n  attr_reader :x#{n}\nend\n"
      uses << "o#{n} = A#{n}.new\n"
      [pv, sv].each do |x|
        uses << "o#{n}.instance_variable_set(:@x#{n}, #{x})\n" <<
          rep.call(car == "reflective_get" ? "o#{n}.instance_variable_get(:@x#{n})" : "o#{n}.x#{n}")
      end
    when "struct_reflect"
      # a Struct's member is no ivar, though an element beside it has one
      # of that name, always the present value
      defs << "S#{n} = Struct.new(:x#{n})\nclass K#{n}\n  def initialize(x) = (@x#{n} = x)\nend\n"
      [pv, sv].each do |x|
        uses << "[S#{n}.new(#{x}), K#{n}.new(#{pv})].each do |o#{n}|\n" \
                "#{indent(rep.call("o#{n}.instance_variable_get(:@x#{n})"), "  ")}end\n"
      end
    when "arr_splice", "arr_fetch", "hash_fetch"
      # an object of a class the receiver's elements did not have, which a
      # splice or a fetch's block brings in, takes the value in an ivar
      defs << "class A#{n}; end\nclass B#{n}; end\n"
      [pv, sv].each do |x|
        uses << case car
                when "arr_splice" then "a#{n} = [A#{n}.new, 0]\na#{n}[0, 1] = [B#{n}.new]\no#{n} = a#{n}[0]\n"
                when "arr_fetch" then "o#{n} = [A#{n}.new, 0].fetch(ARGV.size + 9) { B#{n}.new }\n"
                else "o#{n} = { a: A#{n}.new, b: 0 }.fetch(:c) { B#{n}.new }\n"
                end
        uses << "o#{n}.instance_variable_set(:@x#{n}, #{x})\n" << rep.call("o#{n}.instance_variable_get(:@x#{n})")
      end
    when *WRITERS
      # a write through a handle that may be another class (`[s, 0][0]`),
      # to an object frozen first or not; a write that raises prints the
      # class of what it raised
      defs << if STRUCT_WRITERS.include?(car)
                "S#{n} = Struct.new(:x#{n})\n"
              else
                "class S#{n}\n  attr_accessor :x#{n}\n\n  def initialize(x) = (@x#{n} = x)\nend\n"
              end
      write = case car
              when "setter" then ->(x) { "o#{n}.x#{n} = #{x}" }
              when "send_setter" then ->(x) { "o#{n}.send(:x#{n}=, #{x})" }
              when "struct_aset" then ->(x) { "o#{n}[:x#{n}] = #{x}" }
              else ->(x) { "o#{n}.instance_variable_set(:@z#{n}, #{x})" }
              end
      read = car.start_with?("ivset") ? "o#{n}.instance_variable_get(:@z#{n})" : "o#{n}.x#{n}"
      [pv, sv].each do |x|
        uses << "s#{n} = S#{n}.new(#{pv})\no#{n} = [s#{n}, 0][0]\n"
        uses << "s#{n}.freeze\n" if real[:frozen] == "frozen"
        uses << "begin\n  #{write.call(x)}\n#{indent(rep.call(read), "  ")}rescue => w#{n}\n" \
                "  puts \"#{n} \" + w#{n}.class.to_s\nend\n"
      end
    when "hash"
      uses << "h#{n} = { a: #{pv} }\nh#{n}[:b] = #{sv}\n" << rep.call("h#{n}[:a]") << rep.call("h#{n}[:b]")
    when "arr_push", "arr_lit", "arr_aset", "arr_gap", "arr_reader", "poly_or", "poly_cond"
      a = "a#{n}"
      uses << case car
              when "arr_push" then "#{a} = [#{pv}]\n#{a} << #{sv}\n"
              when "arr_aset" then "#{a} = [#{pv}, #{pv}]\n#{a}[1] = #{sv}\n"
              when "arr_gap" then "#{a} = [#{pv}]\n#{a}[2] = #{sv}\n"
              when "arr_reader"
                defs << "class B#{n}\n  attr_reader :a\n\n  def initialize(z) = (@a = [z])\nend\n"
                a = "o#{n}.a"
                "o#{n} = B#{n}.new(#{pv})\n#{a} << #{sv}\n"
              else "#{a} = [#{pv}, #{sv}]\n"
              end
      if car.start_with?("poly")
        uses << "q#{n} = #{car == "poly_or" ? "ARGV[0] || #{a}" : "ARGV.empty? ? #{a} : \"s\""}\n"
        a = "q#{n}"
      end
      at = car == "arr_gap" ? 2 : 1
      uses << rep.call("#{a}[0]") << rep.call("#{a}[#{at}]")
      uses << rep.call("#{a}[1]") if car == "arr_gap"
      uses << whole.call(a)
    when "captured"
      uses << "x#{n} = #{pv}\nc#{n} = -> do\n#{indent(rep.call("x#{n}"), "  ")}end\n" \
              "c#{n}.call\nx#{n} = #{sv}\nc#{n}.call\n"
    when "each_with_index"
      uses << "[#{pv}, #{sv}].each_with_index do |x#{n}, j#{n}|\n#{indent(rep.call("x#{n}"), "  ")}end\n"
    when "map"
      # the answer map builds holds the value again
      uses << "r#{n} = [#{pv}, #{sv}].map do |x#{n}|\n#{indent(rep.call("x#{n}"), "  ")}  x#{n}\nend\n" <<
        rep.call("r#{n}[1]") << whole.call("r#{n}")
    when "each_slice"
      # the last row is short: its second element is a missing one
      uses << "[#{pv}, #{pv}, #{pv}, #{sv}, #{pv}].each_slice(2) do |w#{n}, x#{n}|\n" \
              "#{indent(rep.call("x#{n}"), "  ")}end\n"
    else raise GeneratorError, "no carrier #{car}"
    end
    defs << "def sc#{n}(*a) = a\n" if row[:read] == "splat_call"
    body = if row[:scope] == "method"
             "def t#{n}\n#{indent(uses, "  ")}end\nt#{n}\n"
           else
             uses
           end
    ["# lines: #{roles(real).join(", ")}\n" + defs + body, real]
  end

  # The case of `row`, numbered `id`. Its realized levels must render back to
  # the same program: a reduction steps from them, and a case file names them.
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
    modes[0] == "promote" ? ["--int-overflow=promote"] : []
  end

  # The cases as one program. The probe compiles one mode to a program; the
  # generator's own listing (`any_mode`) is the CRuby program of them all,
  # each case's mode in its shape.
  def program(cases, any_mode = false)
    fl = any_mode ? [] : flags(cases)
    src = (fl.empty? ? "" : "# spinel #{fl.join(" ")}\n") +
          cases.map { |c| "# case #{c.id}: #{shape(c)}\n" + c.src }.join("\n")
    raise GeneratorError, "a generated program does not parse" unless Prism.parse(src).errors.empty?
    src
  end

  # The values a case's lines read, in the order it prints them: the
  # present one, the source's, a nil the carrier makes of its own (an
  # Array's gap, the element of the answer map builds, a short each_slice
  # row), and an Array carrier's whole Array under an Array read; for
  # struct_reflect, a Struct's and an object's, each value in turn.
  def roles(real)
    return %w[member ivar source_member source_ivar] if real[:carrier] == "struct_reflect"
    own = { "arr_gap" => "gap", "map" => "mapped", "each_slice" => "short" }[real[:carrier]]
    whole = ARRAYS.include?(real[:carrier]) && ARRAY_READS.include?(real[:read]) ? "array" : nil
    ["present", "source", own, whole].compact
  end

  # What kind of difference spinel's lines `got` are from CRuby's `want` in
  # case `c`: the role of the first line that differs, and how it differs.
  def diff_kind(want, got, c)
    if (k = ProbeCommon.count_kind(want, got))
      return k
    end
    at = (0...want.size).find { |i| !ProbeCommon.same_answer?(want[i], got[i]) }
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
      when "--only" then only.merge!(ValueFlowGen.pins(args.shift.to_s))
      else raise ArgumentError
      end
    end
    raise ArgumentError unless (1..ValueFlowGen::FACTORS.size).cover?(strength) && (random.nil? || random.positive?)
  rescue ArgumentError, TypeError => e
    warn e.message unless e.message == "ArgumentError"
    abort "usage: ruby tools/value_flow_gen.rb [--strength T | --random N] [--seed S] [--only F=L,..] [--id ID]"
  end
  if random
    cs = ValueFlowGen.pinned_cases(ValueFlowGen.random_rows(random, seed), only)
    warn "#{cs.size} cases"
  else
    cs, want, got = ValueFlowGen.covering_cases(strength, seed, 100, only)
    warn "#{cs.size} cases, taking #{got} of #{want} #{strength}-way combinations"
  end
  cs = cs.select { |c| c.id == id } if id
  print ValueFlowGen.program(cs, true)
end
