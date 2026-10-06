# Generated nil-narrowing probes (see tools/nil_narrowing_probe.rb).
#
#   ruby tools/nil_narrowing_gen.rb [--strength T | --random N] [--seed S]
#                                   [--strength3 F,F,F..] [--only F=L,..]
#                                   [--id ID]
#
# Nil narrowing (#6481) proves single reads of an Integer or Float local
# non-nil, and the C it generates for such a read drops the nil test: a
# compare, a type test, boxing and a Hash key take the number as it is. So a
# wrong proof is a silent wrong answer, a nil read as a number. The facts come
# from a guard on the local, a write of a value that cannot be nil, a flag set
# together with the local (`found = true` beside `lo = x`), and an index read
# `a[i]` under `while i < a.size` of an array nothing can leave a nil or a gap
# in. Each is undone by what can write the local, the index or the array
# later: a nil written after it, a closure, a loop, a call that runs one, a
# rescue path, a call that hands the array out. The holes found after the
# merge (the flag window's own writes, the block forms that answer their
# receiver) were each one such pair, so the probe crosses them.
#
# A case is one row of FACTORS: the fact, the breaker placed between the fact
# and the read and the loop or block a redo or a helper local runs in, the
# read, the local that carries the value (a local, a method's parameter, a
# block's), the slot's type, and for an index read the array's slot, a call
# that may answer the array itself and its block's parameters, a way to hold
# that answer elsewhere, whether the call is made on the array or on what
# is read back from there, and a write through it that leaves a nil or a
# gap. A level a case has no place for (an alias for a guard, ivar_set for a
# local array, a holder for a plain write) realizes as the factor's first
# level. The rows are pairwise, and ALSO's factors 3-way on top of that.
#
# Every case is a method `t<id>(xv, z, k)` (`N<id>#run` for an ivar array),
# run four times: the local's source `xv` present or nil, and the value `z`
# the breaker writes (and the alias's write runs on) present or nil. The
# first run keeps the fact true; the others leave a nil where it was proven,
# unless the fact itself rules the run out. Each run prints its reads,
# prefixed by its number `k`, or the class of what it raised, through a
# rescue on the method itself: a `begin` around the read would hide the fact
# from the analysis, which follows no fact into one.

require "prism"
require_relative "probe_common"

module NilNarrowingGen
  FACTORS = [
    # guards: `if x`, `unless x.nil?`, `x.nil?`'s false arm, `x == nil` /
    # `x != nil`, `!x`, `x && ...`, `x.nil? || ...`, `while x`, and
    # `return/next/break/raise ... if x.nil?`, and a raise or an exit the
    # case's own class defines, which come back; writes: `x = 7`, `x += 1`,
    # `x ||= 7`, `x &&= 7`; the found-flag window (flag_multi writes the flag
    # and the local twice on each side; flag_nil_mid writes a nil between
    # the local and the flag, flag_nil_after after the flag, flag_false_true
    # sets the flag right after a nil its false vouches for); index reads
    # under `while i < a.size`, `a.size > i`, `i < a.length`.
    [:fact, %w[if_x unless_nil nil_else eq_nil ne_nil not_x and_x nil_or while_x ret_nil next_nil break_nil
               raise_nil raise_own exit_own write_lit op_write or_write and_write flag flag_multi flag_nil_mid flag_nil_after
               flag_false_true ib_lt_size ib_size_gt ib_lt_length]],
    # What writes `z` to the local (for an index read, an index past the
    # end): nothing, a plain write, a proc / lambda / Fiber made before the
    # fact and run after it, a method that yields to a block that writes it
    # (called plainly, by send, through method(:m).call), instance_exec, a
    # proc stored in a global that a method runs, a rescue that writes and retries, an
    # ensure, a redo, a loop (while, until, loop, each, times, begin..end
    # while), a case/when or case/in arm, a multiple assignment, `&&=`, `||=`
    # through another local, instance_variable_set of an ivar array, and a
    # helper local the write goes through, written in the holder below: by
    # `||=` and then an op-assign (a local whose only writes are not all
    # `||=` started at 0, and a block's at nil, so the `||=` was lost), by
    # `&&=`, or by a multiple assignment.
    # Not here: a method's local is out of reach of define_method from a
    # method body (docs/limitations.md: define_singleton_method,
    # singleton_class), of eval (refused) and of binding (no such method), so
    # each would only refuse its whole batch.
    [:breaker, %w[none direct proc lambda fiber yield_blk instance_exec send method_call stored rescue_retry
                  ensure redo while until loop each times post_while case_when case_in masgn and_asgn or_asgn
                  ivar_set helper_or_op helper_and helper_masgn]],
    # The loop or block a redo, and a helper's writes, run in: a `while`
    # (for a redo in the fact's own loop or block, that one), or a block of
    # each, map, select or times. A redo in a map block ran as a `next`.
    [:holder, %w[while each map select times]],
    # Where the nil the breaker writes comes from: z itself (an Integer
    # parameter that may be nil), or, when z is nil, a parameter whose
    # default nil is all it ever holds, or a local only nil is written to:
    # a value whose static type is nil, not an Integer that may be nil.
    [:nil_src, %w[param nil_param nil_local]],
    # the compare or arithmetic each case reads last, after `p` and the
    # reads that do not raise for a nil (read_line)
    [:read, %w[gt lt ge le plus minus]],
    # the local holding the value; for an index read, the element's: `v =
    # a[i]`, a method's parameter, a block's
    [:carrier, %w[local method_param block_param]],
    [:type, %w[int float]],
    # an index read's array: a local, or an ivar its class sets in initialize
    [:slot, %w[local ivar]],
    # A call on the array whose answer may be the array itself, from CRuby's
    # own list: the methods that answer their receiver with or without a
    # block, and those whose Enumerator's `each` does (lazy, to_enum,
    # each_enum). map_enum and dup answer a new array, as controls.
    [:alias_op, %w[none each each_with_index each_index reverse_each each_entry map_bang collect_bang select_bang
                   filter_bang keep_if reject_bang delete_if sort_bang sort_by_bang reverse_bang rotate_bang
                   uniq_bang fill fill_blk tap then itself freeze to_a to_ary deconstruct concat push append
                   prepend unshift insert lshift replace each_slice each_cons cycle product combination
                   permutation repeated_combination repeated_permutation zip_blk lazy to_enum each_enum map_enum
                   dup]],
    # The parameters of alias_op's block: its own (one, or each_with_index's
    # two), two where it yields one value (`|q, r|`, which takes an Array
    # value apart), or a splat `|*qs|`. A block of two or a splat records
    # what it was given, and each run prints that: a product block of two
    # parameters filled only the first.
    [:bparams, %w[one two splat]],
    # Where the answer is held before the write through it: nowhere (the
    # write goes to the array itself), a local, a method's answer, an ivar,
    # a Hash value, a Struct member, an attr_reader, instance_variable_get,
    # the value of a block a user `each` keeps, and the value of `super` in
    # a subclass's initialize (an ivar array only).
    [:alias_way, %w[direct assign method_ret ivar hash struct attr_reader ivar_get block_value super_init]],
    # What alias_op is called on: the array, its answer then held as
    # alias_way says, or the array read back from where alias_way held it
    # (super_init's is always that). A Hash value and a user `each`'s kept
    # block value are boxed, and some Array methods served only a typed
    # receiver: repeated_permutation with a block raised NoMethodError and
    # each_index with a block answered nil.
    [:recv, %w[array held]],
    # The write through it, run when z is nil: past the end, insert past the
    # end, fill from past the end, a range past the end, a splice past the
    # end, concat and push of a nil.
    [:gap, %w[none aset_past insert fill_start aset_range slice_assign concat_nil push_nil]],
    # promote: compiled with --int-overflow=promote, which boxes an Integer
    # slot another way
    [:mode, %w[default promote]],
  ].freeze
  NAMES = FACTORS.map(&:first).freeze
  # The first level of each factor is its simplest; reducing a case walks
  # factors toward it.
  SIMPLEST = FACTORS.to_h { |f, l| [f, l[0]] }.freeze
  # The runs of a case, by the number `k` each line starts with: the source
  # and z present, z nil, the source nil, both nil.
  ROLES = %w[keep break nil nil-break].freeze
  # Facts whose code already puts the breaker in a loop or a block body,
  # where a redo lands (a block parameter's carrier is an `each` block too):
  # a redo whose holder is that loop's kind stays in it, and any other
  # takes a holder of its own.
  OWN = { "while_x" => "while", "next_nil" => "each", "break_nil" => "while" }.freeze
  # The factors whose 3-way combinations a run adds by default
  # (--strength3): an alias_op on a receiver held where it is boxed, of
  # each element type (a Float array's methods are its own).
  ALSO = %i[alias_op alias_way recv type].freeze
  # The breakers that run in a holder.
  HELD = %w[redo helper_or_op helper_and helper_masgn].freeze
  # The alias_ops that take a block, by its own parameters.
  BLOCK_PARAMS = %w[each reverse_each each_entry tap then map_bang collect_bang sort_by_bang select_bang filter_bang
                    keep_if reject_bang delete_if each_slice each_cons combination permutation cycle
                    repeated_combination repeated_permutation product zip_blk lazy to_enum each_enum map_enum]
                 .to_h { |op| [op, %w[q]] }.merge("each_with_index" => %w[q j], "each_index" => %w[j],
                                                   "fill_blk" => %w[j]).freeze

  # A case whose realized levels do not render back to it: a bug here, not in
  # the compiler under test.
  class GeneratorError < StandardError; end

  extend ProbeCommon::Covering
  Case = ProbeCommon::Covering::Case

  module_function

  def indent(s, by = "  ")
    s.gsub(/^(?=.)/, by)
  end

  # Run k's lines for the reads of `x` in a slot of type `t`: `p`, then
  # the reads that answer for a nil without raising (nil?, a type test, an
  # Array, interpolation, a Hash key, <=>), then the read `r`, a compare
  # or arithmetic, which raises for one. A narrowed read drops its nil
  # test, so any of them can answer a number for a nil.
  def read_line(r, x, t, n)
    k = t == "int" ? "Integer" : "Float"
    e = case r
        when "gt" then "(#{x} > 0)"
        when "lt" then "(#{x} < 100)"
        when "ge" then "(#{x} >= 0)"
        when "le" then "(#{x} <= 100)"
        when "plus" then "(#{x} + 1)"
        when "minus" then "(1 - #{x})"
        else raise GeneratorError, "no read #{r}"
        end
    "print \"#{n} \#{k} \"\np(#{x})\n" \
      "puts \"#{n} \#{k} \" + [#{x}.nil?, #{k} === #{x}, [#{x}], \"<\#{#{x}}>\", { #{x} => 1 }, #{x} <=> 0].inspect\n" \
      "puts \"#{n} \#{k} \" + (#{e}).inspect\n"
  end

  # The method's own rescue: the class of what it raised, and the message
  # of a NameError, so a name the generator left undefined is told from a
  # nil (the probe reports that as the generator's bug).
  def rescue_line(n)
    "rescue => e\n  m = e.instance_of?(NameError) ? e.message : \"-\"\n" \
      "  puts \"#{n} \#{k} \" + e.class.to_s + \": \" + m\n"
  end

  # The breaker as [setup, code]: the setup runs before the fact (a
  # closure is made there), the code between the fact and the read. `w`
  # writes `val` to `tgt`; `r` is the read, which a redo, a retry and an
  # ensure also print before their write.
  def breaker(b, w, tgt, val, r, n, guard = "")
    case b
    when "none" then ["", ""]
    when "direct" then ["", w]
    when "proc" then ["pr = proc do\n#{indent(w)}end\n", "pr.call\n"]
    when "lambda" then ["lm = lambda do\n#{indent(w)}end\n", "lm.call\n"]
    when "fiber" then ["fb = Fiber.new do\n  loop do\n#{indent(w, "    ")}    Fiber.yield\n  end\nend\n", "fb.resume\n"]
    when "yield_blk" then ["", "y#{n} do\n#{indent(w)}end\n"]
    when "instance_exec" then ["", "Object.new.instance_exec do\n#{indent(w)}end\n"]
    when "send" then ["", "send(:y#{n}) do\n#{indent(w)}end\n"]
    when "method_call" then ["", "method(:y#{n}).call do\n#{indent(w)}end\n"]
    when "stored" then ["$sk#{n} = proc do\n#{indent(w)}end\n", "k#{n}\n"]
    when "rescue_retry"
      ["tr = 0\n", "begin\n  tr += 1\n#{indent(r)}  raise \"r\" if tr == 1\nrescue RuntimeError\n#{indent(w)}  retry\nend\n"]
    when "ensure" then ["", "begin\n#{indent(r)}ensure\n#{indent(w)}end\n"]
    when "redo" then ["rr = false\n", "#{r}unless rr\n  rr = true\n#{indent(w)}  redo\nend\n"]
    when "while" then ["", "wl = 0\nwhile wl < 1\n  wl += 1\n#{indent(w)}end\n"]
    when "until" then ["", "ul = 0\nuntil ul >= 1\n  ul += 1\n#{indent(w)}end\n"]
    when "loop" then ["", "loop do\n#{indent(w)}  break\nend\n"]
    when "each" then ["", "[0].each do |_q|\n#{indent(w)}end\n"]
    when "times" then ["", "1.times do\n#{indent(w)}end\n"]
    when "post_while" then ["", "begin\n#{indent(w)}end while false\n"]
    when "case_when" then ["", "case z\nwhen nil\n#{indent(w)}else\n#{indent(w)}end\n"]
    when "case_in" then ["", "case z\nin nil\n#{indent(w)}else\n#{indent(w)}end\n"]
    when "masgn" then ["", "mk, #{tgt} = 0, #{val}#{guard}\n"]
    when "and_asgn" then ["", "#{tgt} &&= #{val}#{guard}\n"]
    when "or_asgn" then ["", "og = nil\nog ||= #{val}\n#{tgt} = og#{guard}\n"]
    when "ivar_set" then ["", "instance_variable_set(:@a, @a + [nil]) if z.nil? && i == 0\n"]
    # the helper's `||=` answers 3 and the op-assign 4 before the write
    # takes it; a lost `||=` keeps the local, or raises
    when "helper_or_op" then ["", "hb ||= 3\nhb += 1\n#{tgt} = hb == 4 ? #{val} : #{tgt}#{guard}\n"]
    when "helper_and" then ["", "hb = #{tgt}\nhb &&= #{val}\n#{tgt} = hb#{guard}\n"]
    when "helper_masgn" then ["", "hb, hm = #{val}, 0\n#{tgt} = hb#{guard}\n"]
    else raise GeneratorError, "no breaker #{b}"
    end
  end

  # `code` in a holder of kind `h`, which runs it once.
  def held_in(h, code)
    case h
    when "while" then "while true\n#{indent(code)}  break\nend\n"
    when "each" then "[0].each do |_h|\n#{indent(code)}end\n"
    when "map" then "[0].map do |_h|\n#{indent(code)}end\n"
    when "select" then "[0].select do |_h|\n#{indent(code)}end\n"
    when "times" then "1.times do\n#{indent(code)}end\n"
    else raise GeneratorError, "no holder #{h}"
    end
  end

  # The breaker's code `mid` and the read `r`, with the breaker's holder: a
  # redo's around both, since it runs the read again, unless `own` (the
  # loop or block the fact's code already puts them in) is of the holder's
  # kind; a helper's around its writes.
  def held_breaker(real, mid, r, own)
    h = real[:holder]
    case real[:breaker]
    when "redo" then h == own ? mid + r : held_in(h, mid + r)
    when "helper_or_op", "helper_and", "helper_masgn" then held_in(h, mid) + r
    else mid + r
    end
  end

  # A scalar fact on `x` around `br` (the breaker's code and the read), with
  # the breaker's setup before it. A flag's window comes first, then the
  # setup, so that nothing but simple statements stands beside its writes.
  def scalar_fact(f, br, setup, lit)
    return setup + guard_fact(f, br, lit) unless f.start_with?("flag")
    set = case f
          when "flag", "flag_false_true" then "  x = #{lit}\n  fd = true\n"
          when "flag_multi" then "  x = 1\n  x = #{lit}\n  fd = true\n  fd = true\n"
          when "flag_nil_mid" then "  x = #{lit}\n  x = nil\n  fd = true\n"
          when "flag_nil_after" then "  x = #{lit}\n  fd = true\n  x = nil\n"
          else raise GeneratorError, "no fact #{f}"
          end
    clear = case f
            when "flag_multi" then "fd = false\nfd = false\nx = nil\nx = nil\n"
            when "flag_false_true" then "fd = false\nx = nil\nfd = true\n"
            else "fd = false\nx = nil\n"
            end
    "hv = x\n#{clear}if hv\n#{set}end\n#{setup}#{br}"
  end

  def guard_fact(f, br, lit)
    case f
    when "if_x" then "if x\n#{indent(br)}end\n"
    when "unless_nil" then "unless x.nil?\n#{indent(br)}end\n"
    when "nil_else" then "if x.nil?\n  nil\nelse\n#{indent(br)}end\n"
    when "eq_nil" then "if x == nil\n  nil\nelse\n#{indent(br)}end\n"
    when "ne_nil" then "if x != nil\n#{indent(br)}end\n"
    when "not_x" then "if !x\n  nil\nelse\n#{indent(br)}end\n"
    when "and_x" then "x && (\n#{indent(br)}  true)\n"
    when "nil_or" then "x.nil? || (\n#{indent(br)}  true)\n"
    when "while_x" then "while x\n#{indent(br)}  break\nend\n"
    when "ret_nil" then "return if x.nil?\n#{br}"
    when "next_nil" then "next if x.nil?\n#{br}"
    when "break_nil" then "while true\n  break if x.nil?\n#{indent(br)}  break\nend\n"
    when "raise_nil", "raise_own" then "raise \"nil\" if x.nil?\n#{br}"
    when "exit_own" then "exit if x.nil?\n#{br}"
    when "write_lit" then "x = #{lit}\n#{br}"
    when "op_write" then "x += 1\n#{br}"
    when "or_write" then "x ||= #{lit}\n#{br}"
    when "and_write" then "x &&= #{lit}\n#{br}"
    else raise GeneratorError, "no fact #{f}"
    end
  end

  # The body of a case on a scalar local.
  def scalar_body(n, real, lit)
    f = real[:fact]
    r = read_line(real[:read], "x", real[:type], n)
    # a flag's read is the one under `if fd`
    r = "if fd\n#{indent(r)}end\n" if f.start_with?("flag")
    val, guard = { "param" => ["z", ""], "nil_param" => ["zn", " if z.nil?"],
                   "nil_local" => ["nl", " if z.nil?"] }[real[:nil_src]]
    setup, mid = breaker(real[:breaker], "x = #{val}#{guard}\n", "x", val, r, n, guard)
    # a redo's flag stands outside every loop and block, which the redo
    # would run again
    top = real[:breaker] == "redo" ? setup : ""
    setup = "" if real[:breaker] == "redo"
    br = held_breaker(real, mid, r, OWN[f] || (real[:carrier] == "block_param" ? "each" : nil))
    code = scalar_fact(f, br, setup, lit)
    code = "[0].each do |_q|\n#{indent(code)}end\n" if f == "next_nil" && real[:carrier] != "block_param"
    top = "nl = nil\n#{top}" if real[:nil_src] == "nil_local"
    top + case real[:carrier]
          when "local" then "x = xv\n#{code}"
          when "method_param" then code
          when "block_param" then "[xv].each do |x|\n#{indent(code)}end\n"
          end
  end

  # The call alias_op makes on `s`, its block's parameters as `bp` says.
  def alias_call(op, s, lit, int, bp = "one", n = 0)
    ps = BLOCK_PARAMS[op]
    b = ->(body) { block_of(ps, body, bp, n) }
    case op
    when "none" then s
    # `then` answers its block's value; with two parameters |q, qr| takes the
    # yielded Array apart, so the block answers the receiver (a plain read of
    # the same Array) to keep the holder Array-valued
    when "then" then "#{s}.then #{b.(bp == "two" ? s : "q")}"
    when "each", "reverse_each", "each_entry", "tap" then "#{s}.#{op} #{b.("q")}"
    when "each_with_index" then "#{s}.each_with_index #{b.("q")}"
    when "each_index" then "#{s}.each_index #{b.("j")}"
    when "map_bang", "collect_bang", "sort_by_bang" then "#{s}.#{op.sub("_bang", "!")} #{b.("q")}"
    when "select_bang", "filter_bang", "keep_if" then "#{s}.#{op.sub("_bang", "!")} #{b.("q > 1")}"
    when "reject_bang", "delete_if" then "#{s}.#{op.sub("_bang", "!")} #{b.("q < 2")}"
    when "sort_bang", "reverse_bang", "rotate_bang", "uniq_bang" then "#{s}.#{op.sub("_bang", "!")}"
    when "fill" then "#{s}.fill(#{lit})"
    when "fill_blk" then "#{s}.fill #{b.("j#{int ? "" : " + 0.5"}")}"
    when "itself", "freeze", "to_a", "to_ary", "deconstruct", "dup" then "#{s}.#{op}"
    when "concat" then "#{s}.concat([#{lit}])"
    when "push", "append", "prepend", "unshift" then "#{s}.#{op}(#{lit})"
    when "insert" then "#{s}.insert(1, #{lit})"
    when "lshift" then "(#{s} << #{lit})"
    when "replace" then "#{s}.replace([#{lit}, #{lit}])"
    when "each_slice", "each_cons", "combination", "permutation" then "#{s}.#{op}(2) #{b.("q")}"
    when "cycle", "repeated_combination", "repeated_permutation" then "#{s}.#{op}(1) #{b.("q")}"
    when "product" then "#{s}.product([#{lit}]) #{b.("q")}"
    when "zip_blk" then "#{s}.zip([#{lit}]) #{b.("q")}"
    when "lazy" then "#{s}.lazy.each #{b.("q")}"
    when "to_enum" then "#{s}.to_enum.each #{b.("q")}"
    when "each_enum" then "#{s}.each.each #{b.("q")}"
    when "map_enum" then "#{s}.map.each #{b.("q")}"
    else raise GeneratorError, "no alias_op #{op}"
    end
  end

  # A block of parameters `ps` answering `body`: with them as they are,
  # with a second where there is one (`two`), or as a splat that sets
  # them; the last two add what the block was given to `$pb<n>`.
  def block_of(ps, body, bp, n)
    case bp
    when "one" then "{ |#{ps.join(", ")}| #{body} }"
    when "two" then "{ |#{ps[0]}, qr| $pb#{n} << [#{ps[0]}, qr].inspect; #{body} }"
    when "splat"
      "{ |*qs| $pb#{n} << qs.inspect; #{ps.each_with_index.map { |pn, i| "#{pn} = qs[#{i}]; " }.join}#{body} }"
    else raise GeneratorError, "no bparams #{bp}"
    end
  end

  # The write through `c` that leaves a gap or a nil, when z is nil.
  def gap_line(g, c, gv)
    s = case g
        when "none" then return ""
        when "aset_past" then "#{c}[#{c}.size + 2] = #{gv}"
        when "insert" then "#{c}.insert(#{c}.size + 2, #{gv})"
        when "fill_start" then "#{c}.fill(#{gv}, #{c}.size + 1, 1)"
        when "aset_range" then "#{c}[(#{c}.size + 1)..(#{c}.size + 1)] = #{gv}"
        when "slice_assign" then "#{c}[#{c}.size + 1, 0] = [#{gv}]"
        when "concat_nil" then "#{c}.concat([nil, #{gv}])"
        when "push_nil" then "#{c}.push(nil)"
        else raise GeneratorError, "no gap #{g}"
        end
    "#{s} if z.nil?\n"
  end

  # The body of an index-read case, and the definitions it needs (into
  # `defs`; `cls` gets the ivar array's class's own).
  def index_body(n, real, defs, cls)
    int = real[:type] == "int"
    lit = int ? "7" : "7.5"
    gv = int ? "9" : "9.5"
    ivar = real[:slot] == "ivar"
    s = ivar ? "@a" : "a"
    op = real[:alias_op]
    way = real[:alias_way]
    # where the array is reached: through the class's own reader, method or
    # reflection for an ivar array
    acc = if ivar && way == "attr_reader" then "a"
          elsif ivar && way == "ivar_get" then "instance_variable_get(:@a)"
          else s
          end
    bp = real[:bparams]
    # with recv=held, the array is held first and the call made on what is
    # read back (super_init's own way)
    on_held = real[:recv] == "held" && way != "super_init"
    held = on_held ? acc : alias_call(op, acc, lit, int, bp, n)
    hold = case way
           when "direct" then op == "none" ? "" : "#{held}\n"
           when "assign" then "c = #{held}\n"
           when "method_ret"
             if ivar
               cls << "def ga = #{held}\n"
               "c = ga\n"
             else
               defs << "def id#{n}(q) = q\n"
               "c = id#{n}(#{held})\n"
             end
           when "ivar" then "@c#{n} = #{held}\nc = @c#{n}\n"
           when "hash" then "hh = { k: #{held} }\nc = hh[:k]\n"
           when "struct"
             defs << "S#{n} = Struct.new(:v)\n"
             "c = S#{n}.new(#{held}).v\n"
           when "attr_reader", "ivar_get"
             if ivar
               "c = #{held}\n"
             else
               defs << "class H#{n}\n  attr_reader :v\n\n  def initialize(q) = (@v = q)\nend\n"
               "c = H#{n}.new(#{held})#{way == "attr_reader" ? ".v" : ".instance_variable_get(:@v)"}\n"
             end
           when "block_value"
             defs << "class Bx#{n}\n  attr_reader :got\n\n  def each = (@got = yield)\nend\n"
             "bx = Bx#{n}.new\nbx.each { #{held} }\nc = bx.got\n"
           when "super_init" then ""
           else raise GeneratorError, "no alias_way #{way}"
           end
    hold += "c = #{alias_call(op, "c", lit, int, bp, n)}\n" if on_held
    # what a block of two or a splat was given, once alias_op has run
    unless bp == "one"
      defs << "$pb#{n} = +\"\"\n"
      hold += "puts \"#{n} \#{k} \" + $pb#{n}.inspect\n$pb#{n}.clear\n"
    end
    cls << "attr_reader :a\n" if ivar && way == "attr_reader"
    gap = gap_line(real[:gap], way == "direct" ? s : "c", gv)
    gap = "" if way == "super_init"
    cond = case real[:fact]
           when "ib_lt_size" then "i < #{s}.size"
           when "ib_size_gt" then "#{s}.size > i"
           when "ib_lt_length" then "i < #{s}.length"
           end
    rd = read_line(real[:read], "v", real[:type], n)
    r = case real[:carrier]
        when "local" then "v = #{s}[i]\n#{rd}"
        when "method_param"
          defs << "def r#{n}(v, k)\n#{indent(rd)}end\n"
          "r#{n}(#{s}[i], k)\n"
        when "block_param"
          defs << "def yb#{n}(q) = yield(q)\n"
          "yb#{n}(#{s}[i]) do |v|\n#{indent(rd)}end\n"
        end
    val = "(z.nil? ? i + 9 : i)"
    setup, mid = breaker(real[:breaker], "i = #{val}\n", "i", val, r, n)
    # i is assigned before the setup, so a closure there writes the
    # method's i, and again after it, since making the closure is a call
    loop = "#{setup.empty? ? "" : "i = 0\n#{setup}"}i = 0\nwhile #{cond}\n" \
           "#{indent(held_breaker(real, mid, r, "while"))}  i += 1\nend\n"
    [(ivar ? "" : "a = [3, 1, 2, 2]\n".gsub(/\d/) { |d| int ? d : "#{d}.5" }) + hold + gap + loop, held, gap_line(real[:gap], "c", gv)]
  end

  # The program of `row` and the levels it realizes. Every name a case
  # defines at the top level carries its id, so the cases of one program
  # share nothing the compiler could type across them.
  def build(n, row)
    real = row.dup
    ib = row[:fact].start_with?("ib_")
    real[:nil_src] = "param" if ib
    unless ib
      real[:slot] = "local"
      real[:alias_op] = "none"
      real[:alias_way] = "direct"
      real[:gap] = "none"
    end
    ivar = real[:slot] == "ivar"
    real[:breaker] = "none" if real[:breaker] == "ivar_set" && !(ib && ivar)
    real[:alias_way] = "assign" if real[:alias_way] == "super_init" && !ivar
    real[:holder] = "while" unless HELD.include?(real[:breaker])
    ps = BLOCK_PARAMS[real[:alias_op]]
    real[:bparams] = "one" unless ps && (real[:bparams] != "two" || ps.size == 1)
    real[:recv] = if real[:alias_op] == "none" || real[:alias_way] == "direct" then "array"
                  elsif real[:alias_way] == "super_init" then "held"
                  else real[:recv]
                  end
    # A write through an alias held elsewhere is no use of the slot, so
    # its kind does not matter: past the end. The kinds are for the array
    # itself (alias_way direct), where each is a use the slot must refuse.
    real[:gap] = "aset_past" if ib && real[:alias_way] != "direct"
    int = real[:type] == "int"
    v = int ? "1" : "1.5"
    zv = int ? "5" : "5.5"
    lit = int ? "7" : "7.5"
    defs = +""
    b = real[:breaker]
    defs << "def y#{n} = yield\n" if %w[yield_blk send method_call].include?(b)
    defs << "def k#{n} = $sk#{n}.call\n" if b == "stored"
    runs = [[v, zv], [v, "nil"], ["nil", zv], %w[nil nil]]
    unless ib && ivar
      body = ib ? index_body(n, real, defs, +"")[0] : scalar_body(n, real, lit)
      param = real[:carrier] == "method_param" && !ib ? "x" : "xv"
      param += ", z, k#{real[:nil_src] == "nil_param" ? ", zn = nil" : ""}"
      meth = "def t#{n}(#{param})\n#{indent(body)}#{rescue_line(n)}end\n"
      own = { "raise_own" => "def raise(msg) = nil", "exit_own" => "def exit = nil" }[real[:fact]]
      # a raise or exit of the case's own class, which comes back
      meth = "class R#{n}\n  #{own}\n\n#{indent(meth)}end\n" if own
      call = own ? "R#{n}.new.t#{n}" : "t#{n}"
      prog = defs + meth + runs.each_with_index.map { |(a, z), i| "#{call}(#{a}, #{z}, #{i + 1})\n" }.join
      return [prog, real]
    end
    cls = +""
    body, held, gap = index_body(n, real, defs, cls)
    arr = "[3, 1, 2, 2]".gsub(/\d/) { |d| int ? d : "#{d}.5" }
    prog = "#{defs}class N#{n}\n#{indent(cls)}\n  def initialize\n    @a = #{arr}\n  end\n\n" \
           "  def run(xv, z, k)\n#{indent(body, "    ")}#{indent(rescue_line(n))}  end\nend\n"
    new = "N#{n}.new"
    if real[:alias_way] == "super_init"
      # the subclass's initialize takes the array from super and writes
      # through what alias_op answers of it
      prog << "class M#{n} < N#{n}\n  def initialize(z)\n    c = super()\n" \
              "#{indent(real[:alias_op] == "none" ? "" : "c = #{held.sub("@a", "c")}\n", "    ")}" \
              "#{indent(gap, "    ")}  rescue NoMethodError, FrozenError\n    nil\n  end\nend\n"
      new = "M#{n}.new(%s)"
    end
    prog << runs.each_with_index.map { |(a, z), i| "#{format(new, z)}.run(#{a}, #{z}, #{i + 1})\n" }.join
    [prog, real]
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

  # The cases as one program; the generator's own listing (`any_mode`) is
  # the CRuby program of them all.
  def program(cases, any_mode = false)
    fl = any_mode ? [] : flags(cases)
    src = (fl.empty? ? "" : "# spinel #{fl.join(" ")}\n") +
          cases.map { |c| "# case #{c.id}: #{shape(c)}\n" + c.src }.join("\n")
    raise GeneratorError, "a generated program does not parse" unless Prism.parse(src).errors.empty?
    src
  end

  # What kind of difference spinel's lines `got` are from CRuby's `want` in
  # case `c`: the run of the first line that differs (each line starts with
  # its run's number), and how it differs.
  def diff_kind(want, got, _c)
    at = (0...[want.size, got.size].min).find { |i| !ProbeCommon.same_answer?(want[i], got[i]) }
    if at.nil?
      k = ProbeCommon.count_kind(want, got)
      return k || "exit-status"
    end
    wk, wr = want[at].split(" ", 2)
    gk, gr = got[at].split(" ", 2)
    return "#{ROLES[wk.to_i - 1] || wk}: run" if wk != gk
    "#{ROLES[wk.to_i - 1] || wk}: #{ProbeCommon.answer_kind(wr.to_s, gr.to_s, "value")}"
  end
end

if $PROGRAM_NAME == __FILE__
  strength = 2
  random = nil
  seed = 1
  id = nil
  only = {}
  also = NilNarrowingGen::ALSO
  args = ARGV.dup
  begin
    until args.empty?
      case args.shift
      when "--strength" then strength = Integer(args.shift)
      when "--strength3" then also = NilNarrowingGen.factor_list(args.shift.to_s)
      when "--random" then random = Integer(args.shift)
      when "--seed" then seed = Integer(args.shift)
      when "--id" then id = Integer(args.shift)
      when "--only" then only.merge!(NilNarrowingGen.pins(args.shift.to_s))
      else raise ArgumentError
      end
    end
    raise ArgumentError unless (1..NilNarrowingGen::FACTORS.size).cover?(strength) &&
                               (random.nil? || random.positive?) && (also.empty? || also.size >= 3)
  rescue ArgumentError, TypeError => e
    warn e.message unless e.message == "ArgumentError"
    abort "usage: ruby tools/nil_narrowing_gen.rb [--strength T | --random N] [--seed S] [--strength3 F,F,F..] " \
          "[--only F=L,..] [--id ID]"
  end
  if random
    cs = NilNarrowingGen.pinned_cases(NilNarrowingGen.random_rows(random, seed), only)
    warn "#{cs.size} cases"
  else
    cs, want, got, want3, got3 = NilNarrowingGen.covering_cases(strength, seed, 100, only, also)
    warn "#{cs.size} cases, taking #{got} of #{want} #{strength}-way combinations" +
         (want3 ? " and #{got3} of #{want3} 3-way combinations of #{also.join(", ")}" : "")
  end
  cs = cs.select { |c| c.id == id } if id
  print NilNarrowingGen.program(cs, true)
end
