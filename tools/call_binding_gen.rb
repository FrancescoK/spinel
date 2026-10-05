# Generated call-binding probes (see tools/call_binding_probe.rb).
#
#   ruby tools/call_binding_gen.rb [--strength T | --random N] [--seed S]
#                                  [--only F=L,..] [--id ID]
#
# A case is one row of FACTORS: the path a call takes to reach its parameters,
# the parameter list, the arguments, the class of one argument's value, where
# the arguments' values come from, how many calls reach the parameters,
# whether another class defines a method of the same name, the parameters of a
# child whose bare `super` forwards them, what the callee does with them (and
# through which method), the block the call passes and what the method does
# with it (yields it, answers it beside an early return, or yields it inside a
# begin/ensure it returns through), and the mode the program is compiled in.
# Spinel binds arguments to parameters separately on each path, and its
# inference types a parameter from every call that reaches it, so each of
# these is a factor rather than a constant of the probe.
#
# The argument levels follow the decisions CRuby's binding makes
# (setup_parameters_complex, vm_args.c), relative to the parameters: the
# positional count below the window the parameters take, at its minimum,
# inside it, at its maximum, or past it (into the rest, when there is one); a
# splat empty or not, ahead of other positionals, between them or last;
# literal keywords none, the required ones, all, an unknown one, one written
# twice, a String key, in the parameters' order or the reverse; a `**` operand
# empty, nil, naming a keyword, naming none, String-keyed, not a Hash, or
# boxed, ahead of the literal keywords or after them. A few choices are fixed
# rather than factors: an empty splat sits in the middle of the positionals
# (in front of a lone one), a splat held in a local takes one value (two when
# it trails), and every argument but one is an Integer of its own, so the
# answer shows where each bound.
#
# CRuby runs a call's arguments in source order, each into its place, before
# it binds any of them; a binding that reads an argument where it binds it
# instead reads a later value when an argument after it changes what it
# reads. The `source` factor asks this: every value a literal, or logging the
# order it runs in, or the first read from a local a later argument assigns
# (`m(b: x, a: (x = 2))`), or from an instance variable a later argument's
# call writes (`yield(@v, **change)`). Both were found by hand, in the review
# of #5537 and #5744, past a probe whose values could only log.
#
# The rows come from a covering array of strength T (default 3): every
# combination of levels of any T factors is asked for by some row. A level a
# row cannot take (a known keyword for a method with none, a splat with
# nothing to spread) degrades to the one the case does take, and each case
# records the levels it realized -- rendering the case again from them gives
# the same program, which the generator checks. Combinations the rows asked
# for and no case took are tried again with their levels fixed, smaller ones
# first, from random rows and from cases that already take some of the
# levels (covering_cases); what is still not taken after that is reported as
# such, not as impossible.

require "prism"
require_relative "probe_common"

module CallBindingGen
  FACTORS = [
    # bind_call, raise_new (`raise C, msg` reaching initialize through
    # Exception.exception), a super into an included or prepended module's
    # method, and a parent's class method called through a subclass's Method
    # (self is the subclass) each bind on a path of their own. reopen_random
    # and reopen_array call a method the case adds to a builtin class it
    # reopens (`class Random; def m(..)`), on an object of that class.
    [:path, %w[direct send public_send method_call method_to_proc bind_call instance poly class_method
               inherited_cmethod class_value yield_inline initialize raise_new define_method
               super_explicit super_zsuper super_include super_prepend forward_all forward_anon
               block_yield proc_call lambda_call instance_exec struct struct_kw data reopen_random
               reopen_array]],
    [:req, [0, 1, 2]],
    [:opt, [0, 1, 2]],
    # ivar, global: the default of an optional, positional or keyword,
    # reads an instance variable or a global; the source level `default` has
    # a later argument assign it (`def m(a = $d, b)`, `m(($d = 2; 2))`).
    # CRuby fills a default after every argument ran, and a default filled
    # at the call site at its parameter's slot read the value from before
    # the write (#6005). An instance variable's is assigned only on the
    # paths whose method has the self the arguments run with
    # (SAME_SELF_PATHS); elsewhere the source is a literal. object: an
    # optional positional's default is an object of a class of the case's
    # own (`p2 = Q.new`), which no argument has.
    [:opt_default, %w[int string ref ivar global object]],
    [:rest, %w[none named]],
    [:post, [0, 1]],
    [:kreq, [0, 1]],
    [:kopt, [0, 1, 2]],
    [:kwrest, %w[none named nokw]],
    [:block_param, %w[none named]],
    [:count, %w[min below mid max above]],
    [:splat, %w[none empty_lit empty_var lead_lit lead_var mid_var trail_var]],
    [:kw, %w[none required all unknown repeated string_key]],
    # Keywords bind by name, so a call may write them in any order; one that
    # binds each where its parameter sits runs them in the parameters' order
    # (#5536).
    [:kw_order, %w[params reversed]],
    [:dsplat, %w[none empty nil_lit nil_var known unknown string_key non_hash boxed]],
    [:dsplat_at, %w[after before]],
    [:type, %w[int string nil float symbol array hash object boxed]],
    [:source, %w[literal logged local ivar default]],
    # rebound: one Method local called, then set to another method and
    # called again (`m = A.new.method(:x); m.call(..); m = method(:x)`), so
    # the local's target changes under it. rebound9: an all-Integer call
    # through the method's own Method, then the typed one through a local
    # written nine times, each with a method of its own, the called one
    # last (a local's targets were bound up to eight, and the ninth, typed
    # by the other call, read a String as an Integer, #6007). With
    # body=mutate every call passes the String, so rebound9 is rebound, as
    # int_then_typed is twice. min_then: a first call leaves every optional
    # positional to its default, so a parameter takes a default on one call
    # and an argument on the other (a post-required one takes what the
    # optional took).
    [:sites, %w[one twice int_then_typed rebound rebound9 min_then]],
    # sibling: a class of its own defines a method of the called one's name
    # and parameters, called with the same arguments, so the name has two
    # methods. A callee found by unique name was then not found at all: a
    # caller handed a copy of its String to a parameter the callee grows
    # through a shared handle, and lost the growth (#6065).
    [:name_clash, %w[none sibling]],
    # A bare `super` passes the child's own parameters, as they stand, to the
    # parent's: the child may take the parent's list, or add a `**o`, a rest,
    # or a keyword the parent lacks. `none` is a child with no parameters of
    # its own, calling `super(args)`.
    [:child, %w[none same kwrest rest extra_kw]],
    # mutate: the callee grows a String parameter in place (`s << "x"`) and
    # the call prints the caller's variable after it, which a binding that
    # copies the String on its way in loses (a keyword parameter lost the
    # growth, found by hand).
    [:body, %w[params mutate]],
    # With body=mutate, how the String grows. forward 2: the callee hands
    # the parameter to a method of its own that grows it (`gr(p1)`). seed
    # poly: another call passes that method an Array, so its parameter
    # holds values of several classes, and the callee's is grown through a
    # shared handle; at forward 1 the callee hands it on and grows it too.
    # #6065 needed the seed, the helper and a name two methods share.
    [:forward, [1, 2]],
    [:seed, %w[none poly]],
    # fwd_anon: the call is made inside `def fw(&) = <call>(.., &)`, which
    # hands on the block it is given; through Method#call that named a
    # proc the forwarder does not declare, and the C did not build (#6007).
    # amp_fwd: the call is made inside such a forwarder, but passes a proc
    # of its own (`lp = proc { "lp" }; m(.., &lp)`), which CRuby binds in
    # place of the forwarder's block. at_super: a bare super writes a
    # literal block of its own (`super { :sup }`); elsewhere it is literal.
    [:block, %w[none literal amp fwd_anon amp_fwd at_super]],
    # kept: a method that yields to a block also stores it, and a later
    # call runs the block with values of another type (`@kb = b` beside
    # `yield 1`, then `@kb.call("s")`). A block parameter typed from the
    # yields alone read the String as an Integer (#6033).
    [:block_use, %w[yield kept]],
    # What the method the call reaches does with the block the call passes
    # (CALLEE_PATHS): nothing more than its parameters say (plain); records
    # its parameters through a method (rc<id>) and answers the block's value
    # (yield); answers its parameters on one call and the block's value on
    # the next (early: `return [..] if $r = !$r; yield`, a method of two
    # answer types); or yields, then returns its parameters through rc<id>
    # from inside a begin/ensure, the call made as a statement (ensure: a
    # return's call skipped, #7141's review). ivar: the method writes an
    # instance variable of its first optional positional and answers what
    # it reads back in place of it, with an object default.
    [:callee, %w[plain yield early ensure ivar]],
    # promote: compiled with --int-overflow=promote, which widens Integer
    # values and so the types every binding reads (#5744 met a yield that
    # did not build only there).
    [:mode, %w[default promote]],
  ].freeze
  NAMES = FACTORS.map(&:first).freeze
  # The first level of each factor is its simplest; reducing a case walks
  # factors toward it.
  SIMPLEST = FACTORS.to_h { |f, l| [f, l[0]] }.freeze
  STRUCT_PATHS = %w[struct struct_kw data].freeze
  # Paths whose call already carries the block the parameters are bound by,
  # so the block factor does not apply to them (a Struct or Data takes none,
  # and `raise` passes none to initialize). (instance_exec takes its literal
  # block and no other.)
  BLOCK_PATHS = (%w[yield_inline block_yield instance_exec raise_new] + STRUCT_PATHS).freeze
  # Paths a bare `super` can reach its parameters by: a child class's, or a
  # child of the class that includes or prepends the module.
  BARE_SUPER_PATHS = %w[super_zsuper super_include super_prepend].freeze
  # Paths that call through a Method a local can hold.
  METHOD_PATHS = %w[method_call method_to_proc].freeze
  # Paths whose parameters are a method's named m<id>, the name a sibling
  # class can define too; on the first three that method is a class
  # method.
  CLASS_METHOD_PATHS = %w[class_method inherited_cmethod class_value].freeze
  NAMED_PATHS = (CLASS_METHOD_PATHS + METHOD_PATHS +
                 %w[direct send public_send bind_call instance poly yield_inline define_method forward_all
                    forward_anon super_explicit super_zsuper super_include super_prepend reopen_random
                    reopen_array]).freeze
  # Paths whose block is one the case writes to take the parameters, which
  # the method it is given to can keep.
  KEPT_PATHS = %w[block_yield yield_inline].freeze
  # Paths whose call reaches a method the case writes with `def`, which can
  # yield (the callee factor). initialize answers no value of its own.
  CALLEE_PATHS = %w[direct send public_send method_call method_to_proc bind_call instance poly class_method
                    inherited_cmethod class_value super_explicit super_zsuper super_include super_prepend
                    forward_all forward_anon reopen_random reopen_array].freeze
  # The builtin class a path reopens, and the object its method is called on.
  REOPENED = { "reopen_random" => ["Random", "Random.new(1)"], "reopen_array" => ["Array", "[]"] }.freeze
  # Paths whose parameters bind with the self the call's arguments run
  # with: the top level's, or on a super path the child's method, where
  # the call is made (a bare super's call is made at the top level on a
  # new object). An instance variable an argument assigns is the one a
  # default reads only there. (A rebound Method local's first target is an
  # object's method; its second call is the top level's.)
  SAME_SELF_PATHS = %w[direct send method_call method_to_proc yield_inline forward_all forward_anon block_yield
                       proc_call lambda_call super_explicit super_include super_prepend].freeze
  # The order a parameter list declares its kinds in, where a child's
  # parameter joins it.
  KINDS = %i[req opt rest post kreq kopt kwrest nokw block].freeze

  Case = ProbeCommon::Covering::Case

  # A case whose realized levels do not render back to it: a bug here, not in
  # the compiler under test.
  class GeneratorError < StandardError; end

  # the covering array of FACTORS, the cases of rows and a case's shape
  extend ProbeCommon::Covering

  module_function

  # ---- a row as Ruby ----

  def value(type, n)
    case type
    when "int" then n.to_s
    when "string" then "\"s#{n}\""
    when "nil" then "nil"
    when "float" then "#{n}.5"
    when "symbol" then ":v#{n}"
    when "array" then "[#{n}]"
    when "hash" then "{ v: #{n} }"
    when "object" then "O.new(#{n})"
    when "boxed" then "[#{n}, \"b\"][0]"
    end
  end

  # The variable a default of case `i` reads at opt_default `level`, or nil.
  def default_var(level, i)
    { "ivar" => "@d#{i}", "global" => "$d#{i}" }[level]
  end

  # The parameters of `row`, each [kind, name, default]; records in `real`
  # the levels they realize.
  def params(row, real, i)
    ps = []
    n = 0
    var = default_var(row[:opt_default], i)
    row[:req].times { ps << [:req, "p#{n += 1}"] }
    row[:opt].times do
      name = "p#{n += 1}"
      default = case row[:opt_default]
                when "string" then "\"d#{n}\""
                when "ref" then ps.last && ps.last[1]
                when "object" then "Q#{i}.new"
                else var
                end
      ps << [:opt, name, default || (50 + n).to_s]
    end
    ps << [:rest, "r"] if row[:rest] == "named"
    # a post follows an optional or a rest; with neither it would be one more
    # required, which `req` already asks for
    ps << [:post, "p#{n += 1}"] if row[:post] == 1 && ps.any? { |p| p[0] == :opt || p[0] == :rest }
    row[:kreq].times { |j| ps << [:kreq, "k#{j + 1}"] }
    row[:kopt].times { |j| ps << [:kopt, "k#{row[:kreq] + j + 1}", var || (70 + j).to_s] }
    ps << [:kwrest, "kw"] if row[:kwrest] == "named"
    # `**nil` says a method takes no keywords, so it cannot sit beside any
    ps << [:nokw] if row[:kwrest] == "nokw" && (row[:kreq] + row[:kopt]).zero?
    ps << [:block, "b"] if row[:block_param] == "named"
    opts = ps.select { |p| p[0] == :opt }
    real[:post] = ps.count { |p| p[0] == :post }
    real[:kwrest] = if ps.any? { |p| p[0] == :kwrest } then "named"
                    elsif ps.any? { |p| p[0] == :nokw } then "nokw"
                    else "none"
                    end
    real[:opt_default] = if opts.any? { |p| p[2].start_with?("p") } then "ref"
                         elsif opts.any? { |p| p[2].start_with?("\"") } then "string"
                         elsif opts.any? { |p| p[2].start_with?("Q") } then "object"
                         elsif var && ps.any? { |p| p[2] == var } then row[:opt_default]
                         else "int"
                         end
    ps
  end

  # The level of `child` a case on `path` takes: a child only on a bare-super
  # path, where it takes at least the parent's list.
  def child_level(path, child)
    return "none" unless BARE_SUPER_PATHS.include?(path)
    child == "none" && path == "super_zsuper" ? "same" : child
  end

  # The parameters of the child whose bare `super` forwards to `ps`, or nil
  # when `child` would give it the parent's list: a rest the parent has, or
  # a `**` rest it has (a `**o` would only rename it; one in place of
  # `**nil` is a list of its own).
  def child_params(child, ps)
    add = lambda do |cps, p|
      (cps + [p]).each_with_index.sort_by { |q, x| [KINDS.index(q[0]), x] }.map(&:first)
    end
    case child
    when "none", "same" then ps
    when "kwrest"
      ps.any? { |p| p[0] == :kwrest } ? nil : add.call(ps.reject { |p| p[0] == :nokw }, [:kwrest, "o"])
    when "rest" then ps.any? { |p| p[0] == :rest } ? nil : add.call(ps, [:rest, "a"])
    when "extra_kw" then add.call(ps.reject { |p| p[0] == :nokw }, [:kopt, "kx", "90"])
    end
  end

  def param_src(ps)
    ps.map do |kind, name, default|
      case kind
      when :req, :post then name
      when :opt then "#{name} = #{default}"
      when :rest then "*#{name}"
      when :kreq then "#{name}:"
      when :kopt then "#{name}: #{default}"
      when :kwrest then "**#{name}"
      when :nokw then "**nil"
      when :block then "&#{name}"
      end
    end.join(", ")
  end

  # The callee's answer: its parameters, after `lead` (a tag or self); with
  # `grow`, that statement first (it grows a parameter in place).
  def body_src(ps, lead = nil, grow = nil, callee = "plain", i = nil)
    reflect = callee == "ivar" ? ps.find { |p| p[0] == :opt }[1] : nil
    vals = ps.filter_map do |kind, name|
      next if kind == :nokw
      next "(#{name} ? #{name}.call : nil)" if kind == :block
      # an Integer argument is frozen: its write raises, and its read is nil
      next name unless name == reflect
      "(#{name}.instance_variable_set(:@z#{i}, 7) rescue nil; #{name}.instance_variable_get(:@z#{i}))"
    end
    vals.unshift(lead) if lead
    list = "[#{vals.join(", ")}]"
    grow ? "(#{grow}; #{list})" : list
  end

  # The method `name` of case `i`, taking `pl` and answering `list` as
  # `callee` says: `yield` records it through rc<id> and answers the
  # block's value, `early` answers it on every other call and the block's
  # value on the rest, `ensure` yields and then returns it through rc<id>
  # from inside a begin/ensure.
  def def_src(name, pl, list, callee, i)
    case callee
    when "yield" then "def #{name}(#{pl}) = (rc#{i}(#{list}); yield)\n"
    when "early" then "def #{name}(#{pl})\n  return #{list} if ($r#{i} = !$r#{i})\n\n  yield\nend\n"
    when "ensure"
      "def #{name}(#{pl})\n  begin\n    yield\n    return rc#{i}(#{list})\n  ensure\n    $l << 0\n  end\nend\n"
    else "def #{name}(#{pl}) = #{list}\n"
    end
  end

  # How the callee of case `i` grows its parameter `name`: in place, or
  # through gr<id> (forward 2), which a seed also hands an Array; at
  # forward 1 a seeded callee hands it to gr<id> and grows it itself too.
  def grow_src(i, name, forward, seed)
    own = forward == 2 ? "gr#{i}(#{name})" : "#{name} << \"x\""
    seed == "poly" && forward == 1 ? "gr#{i}(#{name}); #{own}" : own
  end

  # The parameter the typed value binds to without asking the binding the
  # probe checks: a leading required takes the first positional, a declared
  # keyword its key. Nil for any other place.
  def mutated_param(ps, into)
    case into
    when :pos, :prelude then ps[0] && ps[0][0] == :req ? ps[0][1] : nil
    when String then ps.find { |p| %i[kreq kopt].include?(p[0]) && p[1] == into }&.[](1)
    end
  end

  # The positional counts the parameters take: the minimum, the maximum (nil
  # past a rest), and the most before the rest. A Struct takes up to one per
  # member, a keyword Struct none, a Data exactly one per member.
  def window(path, ps)
    if STRUCT_PATHS.include?(path)
      m = ps.count { |p| %i[req opt post rest kreq kopt].include?(p[0]) }
      return { "struct" => [0, m, m], "struct_kw" => [0, 0, 0], "data" => [m, m, m] }[path]
    end
    lo = ps.count { |p| p[0] == :req || p[0] == :post }
    top = ps.count { |p| %i[req opt post].include?(p[0]) }
    [lo, ps.any? { |p| p[0] == :rest } ? nil : top, top]
  end

  # The argument list of one call as source, the locals it reads, the
  # methods it calls that the case defines, and where the typed value went.
  # The first value is of class `type` and every other an Integer, each its
  # own; with `mutate` the typed value is a String the caller holds in
  # v<tag>. Records in `real` the levels the call takes.
  def args_src(row, ps, real, type, tag, mutate)
    # `raise C, msg` hands Exception.exception one argument
    row = row.merge(splat: "none", kw: "none", dsplat: "none") if row[:path] == "raise_new"
    nv = 0
    typed = nil # where the typed value went: :pos, :prelude, or a keyword's key
    val = lambda do |into|
      nv += 1
      first = typed.nil?
      typed ||= into
      [first ? type : "int", nv, first]
    end
    # A value the call runs where it stands is a marker until the list is
    # laid out, then rendered by the source factor in source order.
    slots = []
    lit = lambda do |v|
      next "v#{tag}" if mutate && v[2]
      slots << v
      "\u0000#{slots.size - 1}\u0000"
    end
    # a local's values run where it is set, ahead of the call, so they do not
    # log the order the call's arguments run in
    plain = ->(v) { mutate && v[2] ? "v#{tag}" : value(v[0], v[1]) }
    lo, hi, top = window(row[:path], ps)
    npos = case row[:count]
           when "min" then lo
           when "below" then lo - 1
           when "mid" then [lo + 1, top].min
           when "max" then top
           when "above" then top + (hi ? 1 : 2)
           end
    npos = 1 if row[:path] == "raise_new"
    npos = 0 if npos.negative?
    real[:count] = if npos < lo then "below"
                   elsif npos == lo then "min"
                   elsif npos > top then "above"
                   elsif npos == top then "max"
                   else "mid"
                   end
    vals = Array.new(npos) { val.call(:pos) }
    prelude = []
    items = vals.map(&lit)
    splat = row[:splat]
    case splat
    when "empty_lit" then items.insert(items.size / 2, "*[]")
    when "empty_var"
      prelude << "e#{tag} = []"
      items.insert(items.size / 2, "*e#{tag}")
    when "lead_lit", "lead_var", "mid_var", "trail_var"
      if vals.empty?
        items = ["*[]"]
        splat = "empty_lit"
      else
        take, from = case splat
                     when "lead_lit" then [[vals.size, 2].min, 0]
                     when "lead_var" then [1, 0]
                     when "mid_var" then [1, vals.size >= 3 ? 1 : 0]
                     else [[vals.size, 2].min, vals.size - [vals.size, 2].min]
                     end
        inner = vals[from, take]
        if splat == "lead_lit"
          spl = "*[#{inner.map(&lit).join(", ")}]"
        else
          prelude << "s#{tag} = [#{inner.map(&plain).join(", ")}]"
          spl = "*s#{tag}"
          typed = :prelude if typed == :pos && from.zero?
        end
        items = items[0, from] + [spl] + items[(from + take)..]
        unless splat == "lead_lit"
          after = from + take < vals.size
          splat = if from.zero? && after then "lead_var"
                  elsif from.positive? && after then "mid_var"
                  else "trail_var"
                  end
        end
      end
    end
    real[:splat] = splat
    kwnames = ps.select { |p| p[0] == :kreq || p[0] == :kopt }.map { |p| p[1] }
    kreq = ps.select { |p| p[0] == :kreq }.map { |p| p[1] }
    kws = [] # [key, source]
    kv = ->(k) { [k, "#{k}: #{lit.call(val.call(k))}"] }
    case row[:kw]
    when "required" then kreq.each { |k| kws << kv.call(k) }
    when "all" then kwnames.each { |k| kws << kv.call(k) }
    when "unknown" then (kreq + ["z"]).each { |k| kws << kv.call(k) }
    when "repeated"
      kreq.each { |k| kws << kv.call(k) }
      2.times { kws << kv.call(kwnames[0] || "z") }
    when "string_key"
      kreq.each { |k| kws << kv.call(k) }
      kws << ["\"s\"", "\"s\" => #{lit.call(val.call("\"s\""))}"]
    end
    real[:kw] = if kws.empty? then "none"
                elsif row[:kw] == "all" && kwnames == kreq then "required"
                else row[:kw]
                end
    # reversed only where that changes the order of the keys
    keys = kws.map(&:first)
    real[:kw_order] = row[:kw_order] == "reversed" && keys.reverse != keys ? "reversed" : "params"
    kws.reverse! if real[:kw_order] == "reversed"
    ds = nil
    dkey = nil
    case row[:dsplat]
    when "empty" then prelude << "h#{tag} = {}"
    when "nil_var" then prelude << "h#{tag} = nil"
    when "nil_lit" then ds = "**nil"
    when "known", "boxed"
      dkey = kwnames[0] || "z"
      h = "{ #{dkey}: #{plain.call(val.call(dkey))} }"
      prelude << (row[:dsplat] == "boxed" ? "h#{tag} = [#{h}, 0][0]" : "h#{tag} = #{h}")
    when "unknown"
      dkey = "z"
      prelude << "h#{tag} = { z: #{plain.call(val.call("z"))} }"
    when "string_key"
      dkey = "\"s\""
      prelude << "h#{tag} = { \"s\" => #{plain.call(val.call("\"s\""))} }"
    when "non_hash" then prelude << "h#{tag} = true"
    end
    real[:dsplat] = row[:dsplat] == "known" && kwnames.empty? ? "unknown" : row[:dsplat]
    ds ||= "**h#{tag}" if row[:dsplat] != "none"
    # A `**` merges in source order, so whether it comes ahead of the literal
    # keywords or after them decides which of two values for one key binds.
    at = ds && !kws.empty? ? row[:dsplat_at] : "after"
    real[:dsplat_at] = at
    if ds
      at == "before" ? kws.unshift([dkey, ds]) : kws.push([dkey, ds])
    end
    # the typed value binds only when no later key replaces it; it sits in a
    # literal keyword, never in the `**` entry, which may come ahead of it
    if typed.is_a?(String)
      first = kws.index { |k, src| k == typed && src != ds }
      typed = nil if first && kws[(first + 1)..].any? { |k, _| k == typed }
    end
    real[:type] = typed.nil? ? "int" : type
    args = (items + kws.map(&:last)).join(", ")
    # The values' sources, in the order the call runs them. A local or an
    # instance variable is read by the first value and changed by a later
    # argument: a local by assigning it, an instance variable by a call --
    # the last value's, or the `**` operand's when that comes last.
    marks = args.scan(/\u0000(\d+)\u0000/).flatten.map(&:to_i)
    ds_last = ds&.start_with?("**h") && kws.last&.last == ds
    # like the typed value, the read binds only when no later key replaces
    # it; a read that binds nowhere asks nothing
    read_at = marks.empty? ? nil : kws.index { |_, src| src.include?("\u0000#{marks.first}\u0000") }
    replaced = read_at && kws[(read_at + 1)..].any? { |k, _| k == kws[read_at][0] }
    # the variable a default reads, which the last value run in place assigns
    dvar = STRUCT_PATHS.include?(row[:path]) ? nil : ps.filter_map { |p| p[2] if p[2]&.match?(/\A[@$]d\d+\z/) }.first
    source = case row[:source]
             when "logged" then marks.empty? ? "literal" : "logged"
             when "default" then dvar && !marks.empty? ? "default" : "literal"
             when "local" then marks.size >= 2 && !replaced ? "local" : "literal"
             when "ivar" then !marks.empty? && (ds_last || marks.size >= 2) && !replaced ? "ivar" : "literal"
             else "literal"
             end
    real[:source] = source
    defs = +""
    args = args.gsub(/\u0000(\d+)\u0000/) do
      j = Regexp.last_match(1).to_i
      t, n, = slots[j]
      v = value(t, n)
      if source == "logged" then "($l << #{n}; #{v})"
      elsif source == "default" then j == marks.last ? "(#{dvar} = #{v}; #{v})" : v
      elsif source == "literal" || !(j == marks.first || j == marks.last) then v
      elsif j == marks.first
        prelude << "#{source == "ivar" ? "@" : ""}u#{tag} = #{v}"
        "#{source == "ivar" ? "@" : ""}u#{tag}"
      elsif source == "local" then "(u#{tag} = #{v})"
      elsif ds_last then v
      else "g#{tag}(#{v})"
      end
    end
    if source == "ivar"
      defs << "def g#{tag}(v) = (@u#{tag} = 0; v)\n"
      args = args.delete_suffix(ds) + "**g#{tag}(h#{tag})" if ds_last
    end
    prelude.unshift("v#{tag} = +#{value("string", 1)}") if mutate && !typed.nil?
    # a default's variable starts each call at 0
    prelude.unshift("#{dvar} = 0") if dvar
    [args, prelude, defs, typed]
  end

  # With fwd_anon the call hands on the block its forwarder is given; with
  # amp_fwd it passes a proc of its own instead.
  def call_src(name, args, row, tag, prelude)
    case BLOCK_PATHS.include?(row[:path]) ? "none" : row[:block]
    when "literal" then "#{name}(#{args}) { :blk }"
    when "amp"
      prelude << "blk#{tag} = proc { :blk }" unless prelude.include?("blk#{tag} = proc { :blk }")
      "#{name}(#{[args, "&blk#{tag}"].reject(&:empty?).join(", ")})"
    when "fwd_anon" then "#{name}(#{[args, "&"].reject(&:empty?).join(", ")})"
    when "amp_fwd"
      prelude << "lp#{tag} = proc { \"lp\" }" unless prelude.include?("lp#{tag} = proc { \"lp\" }")
      "#{name}(#{[args, "&lp#{tag}"].reject(&:empty?).join(", ")})"
    else "#{name}(#{args})"
    end
  end

  # One line per call: `ID <answer> <order>` or `ID <Class>: <message> <order>`.
  def report(id, call, indent = "")
    <<~RUBY.gsub(/^/, indent)
      $l.clear
      begin
        puts "#{id} " + (#{call}).inspect + " " + $l.inspect
      rescue => e#{id}
        puts "#{id} " + e#{id}.class.to_s + ": " + e#{id}.message + " " + $l.inspect
      end
    RUBY
  end

  # The calls a case makes: one, the same one twice (twice through one
  # Method local when rebound, the first with fewer positionals when
  # min_then), or an all-Integer one ahead of the typed one.
  def site_types(row)
    # a literal block given to instance_exec is reached by its one call
    return [row[:type]] if row[:path] == "instance_exec"
    case row[:sites]
    when "one" then [row[:type]]
    when "twice", "rebound", "min_then" then [row[:type], row[:type]]
    else ["int", row[:type]]
    end
  end

  # The writes of a rebound Method local ahead of call `s`: its first
  # target ahead of the first call, the top-level method ahead of the
  # second; with rebound9 all nine ahead of the second, and the first call
  # reads no local.
  def rebound_src(i, m, s, sites)
    writes = ["C#{i}.new.method(:#{m})"]
    writes += (2..8).map { |k| "D#{i}_#{k}.new.method(:#{m})" } if sites == "rebound9"
    writes << "method(:#{m})"
    writes = sites == "rebound9" ? (s.zero? ? [] : writes) : [writes[s]]
    writes.map { |w| "q#{i} = #{w}\n" }.join
  end

  # The arguments a kept block is called with later, of another type than
  # the calls that typed it: a String for each positional and required
  # keyword it takes, or a Symbol where the typed value was a String the
  # body does not grow.
  def kept_args(ps, type, mutate)
    n = 0
    v = -> { type == "string" && !mutate ? ":k#{n += 1}" : "+\"k#{n += 1}\"" }
    pos = ps.select { |p| %i[req opt post].include?(p[0]) }.map { v.call }
    (pos + ps.select { |p| p[0] == :kreq }.map { |p| "#{p[1]}: #{v.call}" }).join(", ")
  end

  # The program of `row` and the levels it realizes. Every name a case
  # defines carries its id, so the cases of one program share nothing the
  # compiler could type across them.
  def build(i, row)
    asked = row
    if row[:body] == "mutate"
      # a Struct's constructor is not a body the case writes
      return build(i, asked.merge(body: "params")) if STRUCT_PATHS.include?(row[:path])
      # the grown value is a String, and every call passes it
      row = row.merge(type: "string")
      row = row.merge(sites: "twice") if row[:sites] == "int_then_typed"
      # the nine-target local's Integer call would pass the String too
      row = row.merge(sites: "rebound") if row[:sites] == "rebound9"
    end
    # an instance variable's default sees the argument's write only with
    # the self the call is made with
    if row[:source] == "default" && row[:opt_default] == "ivar" &&
       !(SAME_SELF_PATHS.include?(row[:path]) && child_level(row[:path], row[:child]) == "none")
      row = row.merge(source: "literal")
    end
    mutate = row[:body] == "mutate"
    if %w[rebound rebound9].include?(row[:sites]) && !METHOD_PATHS.include?(row[:path])
      row = row.merge(sites: "twice")
    end
    real = row.dup
    real[:block] = "none" if BLOCK_PATHS.include?(row[:path])
    real[:name_clash] = "none" unless NAMED_PATHS.include?(row[:path])
    real[:block_use] = "yield" unless KEPT_PATHS.include?(row[:path])
    ps = params(row, real, i)
    child = child_level(row[:path], row[:child])
    cps = child_params(child, ps)
    child, cps = "same", ps if cps.nil?
    real[:child] = child
    bare = child != "none"
    # a block of a super's own is a literal one where the call is the super
    if real[:block] == "at_super" && !bare
      row = row.merge(block: "literal")
      real[:block] = "literal"
    end
    rebound = %w[rebound rebound9].include?(real[:sites])
    fwd = %w[fwd_anon amp_fwd].include?(real[:block])
    kept = real[:block_use] == "kept"
    pl = param_src(ps)
    cpl = param_src(cps)
    m = "m#{i}"
    # a bare super's call binds the child's parameters first. min_then's
    # first call is built last, from the levels the second one realized,
    # with as few positionals as the parameters take and no splat; the
    # levels it realizes itself are not the case's.
    types = site_types(row)
    min_then = row[:sites] == "min_then" && types.size == 2
    sites = []
    (min_then ? types.each_index.to_a.reverse : types.each_index).each do |s|
      tag = "#{i}_#{s}"
      first = min_then && s.zero?
      r, into, type = first ? [real.merge(count: "min", splat: "none"), {}, real[:type]] : [row, real, types[s]]
      call = args_src(r, bare ? cps : ps, into, type, tag, mutate)
      # a typed value a later key replaces binds nowhere: the call is an
      # Integer one, and says so
      call = args_src(r, bare ? cps : ps, into, "int", tag, false) if type != "int" && into[:type] == "int"
      sites[s] = [tag, *call]
    end
    # min_then at the minimum count is twice
    real[:sites] = "twice" if min_then && real[:count] == "min" && real[:splat] == "none"
    mutated = mutate ? mutated_param(ps, sites.last[4]) : nil
    return build(i, asked.merge(body: "params")) if mutate && (real[:type] != "string" || mutated.nil?)
    real[:body] = mutate ? "mutate" : "params"
    real[:forward] = mutate ? row[:forward] : 1
    real[:seed] = mutate ? row[:seed] : "none"
    grow = mutate ? grow_src(i, mutated, real[:forward], real[:seed]) : nil
    body = body_src(ps, nil, grow)
    indent = ->(text, ind) { text.gsub(/^(?=.)/, ind) }
    # The callee factor asks a method the case writes, called with a block
    # (ivar: an optional with an object default, and no String argument,
    # which CRuby's own literal would let take an instance variable).
    callee = CALLEE_PATHS.include?(row[:path]) && !mutate ? row[:callee] : "plain"
    callee = "plain" if %w[yield early ensure].include?(callee) && real[:block] == "none"
    callee = "plain" if callee == "ivar" && (real[:opt_default] != "object" || real[:type] == "string")
    real[:callee] = callee
    # the method the call reaches, as the callee factor writes it
    cdef = lambda do |name, lead = nil, ind = ""|
      indent.call(def_src(name, pl, body_src(ps, lead, grow, callee, i), callee, i), ind)
    end
    defs = +""
    uses = +""
    branches = +""
    sites.each_with_index do |(tag, as, prelude, dfs, _), s|
      defs << dfs
      # the locals, written out once the call is built: a block the call
      # passes with `&` joins them
      pre = ->(ind = "") { prelude.map { |l| "#{ind}#{l}\n" }.join }
      # with a grown String, the caller's variable after the call; with
      # callee=yield, the parameters rc<id> recorded after the block's
      # value; with callee=ensure, the call is a statement and the answer
      # the parameters rc<id> recorded
      out = lambda do |call|
        if mutate then "[#{call}, v#{tag}]"
        elsif callee == "yield" then "[#{call}, $a#{i}]"
        elsif callee == "ensure" then "($a#{i} = nil; #{call}; $a#{i})"
        else call
        end
      end
      # The call where it stands after `lead` and the locals, or with
      # fwd_anon in a forwarder of its own the report gives a literal block;
      # `local`, a local of the top level the call reads, is then the
      # forwarder's argument.
      emit = lambda do |call, lead = "", local = nil, ind = ""|
        if fwd
          defs << "def fw#{tag}(#{[local, "&"].compact.join(", ")})\n#{indent.call(lead, "  ")}#{pre.call("  ")}" \
                  "  #{out.call(call)}\nend\n"
          uses << report(i, "fw#{tag}#{local ? "(#{local})" : ""} { :blk }", ind)
        else
          uses << indent.call(lead, ind) << pre.call(ind) << report(i, out.call(call), ind)
        end
      end
      case row[:path]
      when "direct", "send", "public_send", "method_call", "method_to_proc", "bind_call", "inherited_cmethod",
           "forward_all", "forward_anon"
        target = case row[:path]
                 when "direct" then m
                 when "send" then "send"
                 when "public_send" then "C#{i}.new.public_send"
                 when "method_call", "method_to_proc"
                   (rebound && !(real[:sites] == "rebound9" && s.zero?) ? "q#{i}" : "method(:#{m})") +
                     (row[:path] == "method_call" ? ".call" : ".to_proc.call")
                 when "bind_call" then "C#{i}.instance_method(:#{m}).bind_call"
                 when "inherited_cmethod" then "B#{i}.method(:#{m}).call"
                 else "w#{i}"
                 end
        lead = { "send" => ":#{m}", "public_send" => ":#{m}", "bind_call" => "C#{i}.new" }[row[:path]]
        call = call_src(target, lead ? [lead, as].reject(&:empty?).join(", ") : as, row, tag, prelude)
        emit.call(call, rebound ? rebound_src(i, m, s, real[:sites]) : "")
      when "instance", "class_method", "initialize", "define_method", "reopen_random", "reopen_array"
        recv = { "instance" => "C#{i}.new.#{m}", "class_method" => "C#{i}.#{m}",
                 "initialize" => "C#{i}.new", "define_method" => "C#{i}.new.#{m}" }[row[:path]] ||
               "#{REOPENED[row[:path]][1]}.#{m}"
        call = call_src(recv, as, row, tag, prelude)
        call = "(#{call}).v#{i}" if row[:path] == "initialize"
        emit.call(call)
      when "raise_new"
        emit.call("(begin; raise C#{i}, #{as}; rescue C#{i} => j#{tag}; j#{tag}.v#{i}; end)")
      when "poly", "class_value"
        recvs = row[:path] == "poly" ? "[A#{i}.new, B#{i}.new]" : "[A#{i}, B#{i}]"
        call = call_src("o#{i}.#{m}", as, row, tag, prelude)
        # the locals are set for each receiver, so each call reads what it
        # did not write itself
        uses << "#{recvs}.each do |o#{i}|\n"
        emit.call(call, "", "o#{i}", "  ")
        uses << "end\n"
      when "yield_inline"
        uses << pre.call << report(i, out.call("#{m}(#{as}) { |x#{i}| x#{i} }"))
      when "super_explicit", "super_zsuper", "super_include", "super_prepend"
        if bare
          emit.call(call_src("C#{i}.new.#{m}", as, row, tag, prelude))
        else
          call = call_src("super", as, row, tag, prelude)
          parent = { "super_explicit" => " < B#{i}", "super_prepend" => " < P#{i}" }[row[:path]]
          incl = row[:path] == "super_include" ? "  include M#{i}\n\n" : ""
          # with fwd_anon the child's method is the forwarder
          defs << "class C#{tag}#{parent}\n#{incl}  def #{m}#{fwd ? "(&)" : ""}\n#{pre.call("    ")}    " \
                  "#{out.call(call)}\n  end\nend\n"
          uses << report(i, "C#{tag}.new.#{m}#{fwd ? " { :blk }" : ""}")
        end
      when "block_yield"
        # one literal block, reached by every site: y<id>(s) yields site s's arguments
        branches << "#{s.zero? ? "  if" : "  elsif"} s#{i} == #{s}\n#{pre.call("    ")}    " \
                    "#{out.call("yield(#{as})")}\n"
      when "proc_call", "lambda_call"
        emit.call(call_src("f#{i}.call", as, row, tag, prelude), "", "f#{i}")
      when "instance_exec"
        uses << pre.call << report(i, out.call("Object.new.instance_exec(#{as}) { |#{pl}| #{body} }"))
      when "struct", "struct_kw", "data"
        uses << pre.call << report(i, "S#{i}.new(#{as}).#{row[:path] == "data" ? "to_h" : "to_a"}")
      end
    end
    if row[:path] == "block_yield"
      n = sites.size
      # kept: the method stores its block beside the yields
      keep = kept ? ", &kb#{i})\n  @kb#{i} = kb#{i}\n" : ")\n"
      defs << "def y#{i}(s#{i}#{keep}#{branches}  end\nend\n"
      uses << "#{(0...n).to_a.inspect}.each do |s#{i}|\n" <<
        report(i, "y#{i}(s#{i}) { |#{pl}| #{body} }", "  ") << "end\n"
    end
    # the kept block, run again with values of another type
    if kept
      uses << report(i, "@kb#{i}.call(#{row[:path] == "block_yield" ? kept_args(ps, real[:type], mutate) : "+\"k1\""})")
    end
    # the sibling, called with the first call's arguments
    sibling = ""
    if real[:name_clash] == "sibling"
      tag, as, prelude = sites[0]
      sp = prelude.dup
      cm = CLASS_METHOD_PATHS.include?(row[:path])
      sps = bare ? cps : ps
      sibling = "class N#{i}\n  def #{cm ? "self." : ""}#{m}(#{bare ? cpl : pl}) = " \
                "#{body_src(sps, ":n", mutate ? "#{mutated} << \"x\"" : nil)}\nend\n"
      # a forwarder's block given where the sibling is called
      call = call_src(cm ? "N#{i}.#{m}" : "N#{i}.new.#{m}", as, row.merge(block: fwd ? "literal" : row[:block]),
                      tag, sp)
      uses << sp.map { |l| "#{l}\n" }.join << report(i, mutate ? "[#{call}, v#{tag}]" : call)
    end
    # the method the callee hands its String to, and the call that seeds it
    helper = if real[:forward] == 2 || real[:seed] == "poly"
               "def gr#{i}(v) = v << \"x\"\n" + (real[:seed] == "poly" ? "gr#{i}([])\n" : "")
             else ""
             end
    members = ps.select { |p| %i[req opt post rest kreq kopt].include?(p[0]) }.map { |p| ":#{p[1]}" }
    mod = "module M#{i}\n#{cdef.call(m, nil, "  ")}end\n"
    sup = real[:block] == "at_super" ? "super { :sup }" : "super"
    child_src = ->(parent) { "class C#{i}#{parent}\n  def #{m}(#{cpl}) = #{sup}\nend\n" }
    head = case row[:path]
           when "direct", "send", "method_call", "method_to_proc"
             # rebound: the Method local's first target, a method of the same
             # parameters, and with rebound9 seven more
             target = ->(c, lead) { "class #{c}\n#{cdef.call(m, lead, "  ")}end\n" }
             (rebound ? target.call("C#{i}", ":c") : "") +
               (real[:sites] == "rebound9" ? (2..8).map { |k| target.call("D#{i}_#{k}", ":d#{k}") }.join : "") +
               cdef.call(m)
           when "yield_inline"
             if kept
               # the method keeps its block: its own block parameter, or one it takes for that
               bp = ps.find { |p| p[0] == :block }&.[](1)
               "def #{m}(#{bp ? pl : [pl, "&kb#{i}"].reject(&:empty?).join(", ")}) = " \
                 "(@kb#{i} = #{bp || "kb#{i}"}; yield(#{body}))\n"
             else
               "def #{m}(#{pl}) = yield(#{body})\n"
             end
           when "forward_all" then "#{cdef.call(m)}def w#{i}(...) = #{m}(...)\n"
           when "forward_anon" then "#{cdef.call(m)}def w#{i}(*, **, &) = #{m}(*, **, &)\n"
           when "public_send", "instance", "bind_call" then "class C#{i}\n#{cdef.call(m, nil, "  ")}end\n"
           when "class_method" then "class C#{i}\n#{cdef.call("self.#{m}", nil, "  ")}end\n"
           when "reopen_random", "reopen_array" then "class #{REOPENED[row[:path]][0]}\n#{cdef.call(m, nil, "  ")}end\n"
           when "inherited_cmethod"
             "class A#{i}\n#{cdef.call("self.#{m}", "self", "  ")}end\nclass B#{i} < A#{i}\nend\n"
           when "initialize"
             "class C#{i}\n  attr_reader :v#{i}\n\n  def initialize(#{pl})\n    @v#{i} = #{body}\n  end\nend\n"
           when "raise_new"
             "class C#{i} < StandardError\n  attr_reader :v#{i}\n\n  def initialize(#{pl})\n    @v#{i} = #{body}\n  end\nend\n"
           when "define_method" then "class C#{i}\n  define_method(:#{m}) { |#{pl}| #{body} }\nend\n"
           when "poly"
             "class A#{i}\n#{cdef.call(m, ":a", "  ")}end\nclass B#{i}\n#{cdef.call(m, ":b", "  ")}end\n"
           when "class_value"
             "class A#{i}\n#{cdef.call("self.#{m}", ":a", "  ")}end\n" \
               "class B#{i}\n#{cdef.call("self.#{m}", ":b", "  ")}end\n"
           when "super_explicit" then "class B#{i}\n#{cdef.call(m, nil, "  ")}end\n"
           when "super_zsuper" then "class B#{i}\n#{cdef.call(m, nil, "  ")}end\n" + child_src.call(" < B#{i}")
           when "super_include" then mod + (bare ? child_src.call("").sub("\n", "\n  include M#{i}\n\n") : "")
           when "super_prepend"
             # P's own method, which the prepended module's comes ahead of
             mod + "class P#{i}\n  prepend M#{i}\n\n  def #{m}(*, **, &) = [:p]\nend\n" +
               (bare ? child_src.call(" < P#{i}") : "")
           # one block, so every call reaches the same parameters
           when "proc_call" then "f#{i} = proc { |#{pl}| #{body} }\n"
           # the literal block sits at the call
           when "block_yield", "instance_exec" then ""
           when "lambda_call" then "f#{i} = ->(#{pl}) { #{body} }\n"
           when "struct" then "S#{i} = Struct.new(#{members.join(", ")})\n"
           when "struct_kw" then "S#{i} = Struct.new(#{(members + ["keyword_init: true"]).join(", ")})\n"
           when "data" then "S#{i} = Data.define(#{members.join(", ")})\n"
           end
    if STRUCT_PATHS.include?(row[:path])
      # every parameter is a member; these ask nothing of a constructor
      %i[opt_default kwrest block_param].each { |f| real[f] = SIMPLEST[f] }
    end
    # with an Integer typed value both calls are the same, one twice
    real[:sites] = "twice" if row[:sites] == "int_then_typed" && real[:type] == "int"
    real[:sites] = "one" if row[:path] == "instance_exec"
    # an object default's class, and the method the callee records its
    # parameters through
    helper += "class Q#{i}\n  def inspect = \"q\"\nend\n" if real[:opt_default] == "object"
    helper += "def rc#{i}(v) = ($a#{i} = v)\n" if %w[yield ensure].include?(callee)
    [helper + head + sibling + defs + uses, real]
  end

  # The case of `row`, numbered `id`. Its realized levels must render back to
  # the same program: a reduction steps from them, and a case file names them.
  def render(id, row)
    src, real = build(id, row)
    again, = build(id, real)
    raise GeneratorError, "case #{id} does not render back from its realized levels" unless again == src
    Case.new(id, real, src)
  end

  HEADER = <<~RUBY
    $l = []
    class O
      def initialize(v) = (@v = v)
      def inspect = "O(\#{@v})"
    end
  RUBY

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
    src = (fl.empty? ? "" : "# spinel #{fl.join(" ")}\n") + HEADER + "\n" +
          cases.map { |c| "# case #{c.id}: #{shape(c)}\n" + c.src }.join("\n")
    raise GeneratorError, "a generated program does not parse" unless Prism.parse(src).errors.empty?
    src
  end
end

if $PROGRAM_NAME == __FILE__
  strength = 3
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
      when "--only" then only.merge!(CallBindingGen.pins(args.shift.to_s))
      else raise ArgumentError
      end
    end
    raise ArgumentError unless (1..CallBindingGen::FACTORS.size).cover?(strength) && (random.nil? || random.positive?)
  rescue ArgumentError, TypeError => e
    warn e.message unless e.message == "ArgumentError"
    abort "usage: ruby tools/call_binding_gen.rb [--strength T | --random N] [--seed S] [--only F=L,..] [--id ID]"
  end
  if random
    cs = CallBindingGen.pinned_cases(CallBindingGen.random_rows(random, seed), only)
    warn "#{cs.size} cases"
  else
    cs, want, got = CallBindingGen.covering_cases(strength, seed, 100, only)
    warn "#{cs.size} cases, taking #{got} of #{want} #{strength}-way combinations"
  end
  cs = cs.select { |c| c.id == id } if id
  print CallBindingGen.program(cs, true)
end
