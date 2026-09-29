# Generated call-binding probes (see tools/call_binding_probe.rb).
#
#   ruby tools/call_binding_gen.rb [--strength T | --random N] [--seed S] [--id ID]
#
# A case is one row of FACTORS: the path a call takes to reach its
# parameters, the parameter list, the arguments, the class of one argument's
# value, where the arguments' values come from, how many calls reach the
# parameters, the parameters of a child whose bare `super` forwards them, what
# the callee does with them, the block the call passes, and the mode the
# program is compiled in. Spinel binds arguments to parameters separately on
# each path, and its inference types a parameter from every call that reaches
# it, so each of these is a factor rather than a constant of the probe.
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

module CallBindingGen
  FACTORS = [
    # bind_call, raise_new (`raise C, msg` reaching initialize through
    # Exception.exception), a super into an included or prepended module's
    # method, and a parent's class method called through a subclass's Method
    # (self is the subclass) each bind on a path of their own.
    [:path, %w[direct send public_send method_call method_to_proc bind_call instance poly class_method
               inherited_cmethod class_value yield_inline initialize raise_new define_method
               super_explicit super_zsuper super_include super_prepend forward_all forward_anon
               block_yield proc_call lambda_call instance_exec struct struct_kw data]],
    [:req, [0, 1, 2]],
    [:opt, [0, 1, 2]],
    [:opt_default, %w[int string ref]],
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
    [:source, %w[literal logged local ivar]],
    # rebound: one Method local called, then set to another method and
    # called again (`m = A.new.method(:x); m.call(..); m = method(:x)`), so
    # the local's target changes under it.
    [:sites, %w[one twice int_then_typed rebound]],
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
    [:block, %w[none literal amp]],
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
  # The order a parameter list declares its kinds in, where a child's
  # parameter joins it.
  KINDS = %i[req opt rest post kreq kopt kwrest nokw block].freeze

  Case = Struct.new(:id, :realized, :src)

  # A case whose realized levels do not render back to it: a bug here, not in
  # the compiler under test.
  class GeneratorError < StandardError; end

  module_function

  # ---- the covering array ----

  # Rows covering every `t`-way combination of levels of FACTORS in
  # `uncovered` (all of them when nil), by AETG's greedy construction: each row
  # is the best of a few candidates, each candidate built factor by factor in a
  # random order, each factor taking the level that covers the most
  # combinations not yet covered with the factors already set.
  def covering_array(t, seed, candidates = 5, uncovered = nil)
    rng = Random.new(seed)
    k = FACTORS.size
    sizes = FACTORS.map { |_, l| l.size }
    tuples = (0...k).to_a.combination(t).to_a
    tindex = tuples.each_with_index.to_h
    uncovered = (uncovered || all_tuples(t)).dup
    # sampled with lazy deletion: a Hash has no random access
    pool = uncovered.keys
    rows = []
    until uncovered.empty?
      best = nil
      best_gain = -1
      candidates.times do
        row = Array.new(k)
        # start from a combination still uncovered, so every row gains
        j = rng.rand(pool.size)
        until uncovered.key?(pool[j])
          pool[j] = pool.last
          pool.pop
          j = rng.rand(pool.size)
        end
        ti, ls = unkey(pool[j], t)
        tuples[ti].each_with_index { |f, x| row[f] = ls[x] }
        (0...k).to_a.shuffle(random: rng).each do |f|
          next if row[f]
          set = (0...k).select { |g| row[g] }
          best_l = nil
          best_n = -1
          (0...sizes[f]).to_a.shuffle(random: rng).each do |l|
            n = 0
            set.combination(t - 1) do |others|
              tu = (others + [f]).sort
              n += 1 if uncovered[key(tindex[tu], tu.map { |g| g == f ? l : row[g] })]
            end
            if n > best_n
              best_n = n
              best_l = l
            end
          end
          row[f] = best_l
        end
        gain = tuples.each_with_index.count { |tu, i| uncovered[key(i, tu.map { |f| row[f] })] }
        if gain > best_gain
          best_gain = gain
          best = row
        end
      end
      tuples.each_with_index { |tu, i| uncovered.delete(key(i, tu.map { |f| best[f] })) }
      rows << best
    end
    rows.map { |r| NAMES.each_with_index.to_h { |f, i| [f, FACTORS[i][1][r[i]]] } }
  end

  # Every `t`-way combination of levels, as the keys covering_array uses.
  def all_tuples(t)
    sizes = FACTORS.map { |_, l| l.size }
    h = {}
    (0...FACTORS.size).to_a.combination(t).each_with_index do |tu, i|
      tu.map { |f| (0...sizes[f]).to_a }.reduce([[]]) { |acc, ls| acc.product(ls).map { |a, l| a + [l] } }.each do |ls|
        h[key(i, ls)] = true
      end
    end
    h
  end

  # The `t`-way combinations the realized levels of `cases` take.
  def tuples_of(cases, t)
    idx = FACTORS.map { |_, l| l.each_with_index.to_h }
    combos = (0...FACTORS.size).to_a.combination(t).to_a
    h = {}
    cases.each do |c|
      lv = NAMES.each_with_index.map { |f, i| idx[i][c.realized[f]] }
      combos.each_with_index { |tu, i| h[key(i, tu.map { |f| lv[f] })] = true }
    end
    h
  end

  # Cases for every `t`-way combination some case takes. The covering array's
  # rows ask for levels; a combination they asked for and no case took is
  # then tried from up to `tries` rows with its levels fixed -- random ones,
  # and the realized levels of the cases that take the most of them, which
  # carry what those levels need of the other factors (a Method local
  # rebound, a path through a Method) -- and the first case that takes it
  # joins. Smaller combinations go first, and a combination is tried only
  # when every one of its parts is taken: one with a part no case takes (a
  # rebound local on a bare super's path) cannot be taken either. Answers
  # the cases, how many combinations there are, and how many the cases take.
  def covering_cases(t, seed, tries = 100)
    cases = self.cases(covering_array(t, seed))
    rng = Random.new(seed)
    want = got = nil
    (1..t).each do |s|
      want = all_tuples(s)
      got = tuples_of(cases, s)
      parts = s > 1 ? tuples_of(cases, s - 1) : {}
      combos = (0...FACTORS.size).to_a.combination(s).to_a
      part_index = (0...FACTORS.size).to_a.combination(s - 1).each_with_index.to_h
      want.each_key do |kk|
        next if got.key?(kk)
        ti, ls = unkey(kk, s)
        fs = combos[ti]
        next if s > 1 && (0...s).any? do |x|
          parts[key(part_index[fs[0...x] + fs[(x + 1)..]], ls[0...x] + ls[(x + 1)..])].nil?
        end
        fixed = fs.each_with_index.to_h { |f, x| [NAMES[f], FACTORS[f][1][ls[x]]] }
        from = nil
        tries.times do |n|
          if n.odd?
            from ||= begin
              near = cases.group_by { |c| fixed.count { |f, l| c.realized[f] == l } }
              near.delete(0)
              near.empty? ? [] : near[near.keys.max]
            end
          end
          base = n.odd? && !from.empty? ? from[rng.rand(from.size)].realized : random_row(rng)
          c = render(cases.last.id + 1, base.merge(fixed))
          next unless fixed.all? { |f, l| c.realized[f] == l }
          cases << c
          got.merge!(tuples_of([c], s))
          parts.merge!(tuples_of([c], s - 1)) if s > 1
          break
        end
      end
    end
    [cases, want.size, want.count { |kk, _| got.key?(kk) }]
  end

  def key(ti, ls)
    ls.reduce(ti) { |acc, l| acc * 64 + l }
  end

  def unkey(kk, t)
    ls = []
    t.times { ls.unshift(kk % 64); kk /= 64 }
    [kk, ls]
  end

  def random_row(rng)
    FACTORS.to_h { |f, l| [f, l[rng.rand(l.size)]] }
  end

  def random_rows(n, seed)
    rng = Random.new(seed)
    Array.new(n) { random_row(rng) }
  end


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

  # The parameters of `row`, each [kind, name, default]; records in `real`
  # the levels they realize.
  def params(row, real)
    ps = []
    n = 0
    row[:req].times { ps << [:req, "p#{n += 1}"] }
    row[:opt].times do
      name = "p#{n += 1}"
      default = case row[:opt_default]
                when "string" then "\"d#{n}\""
                when "ref" then ps.last && ps.last[1]
                end
      ps << [:opt, name, default || (50 + n).to_s]
    end
    ps << [:rest, "r"] if row[:rest] == "named"
    # a post follows an optional or a rest; with neither it would be one more
    # required, which `req` already asks for
    ps << [:post, "p#{n += 1}"] if row[:post] == 1 && ps.any? { |p| p[0] == :opt || p[0] == :rest }
    row[:kreq].times { |j| ps << [:kreq, "k#{j + 1}"] }
    row[:kopt].times { |j| ps << [:kopt, "k#{row[:kreq] + j + 1}", (70 + j).to_s] }
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
  # `mutated`, that parameter grown in place first.
  def body_src(ps, lead = nil, mutated = nil)
    vals = ps.filter_map do |kind, name|
      next if kind == :nokw
      kind == :block ? "(#{name} ? #{name}.call : nil)" : name
    end
    vals.unshift(lead) if lead
    list = "[#{vals.join(", ")}]"
    mutated ? "(#{mutated} << \"x\"; #{list})" : list
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
    source = case row[:source]
             when "logged" then marks.empty? ? "literal" : "logged"
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
    [args, prelude, defs, typed]
  end

  def call_src(name, args, row, tag, prelude)
    case BLOCK_PATHS.include?(row[:path]) ? "none" : row[:block]
    when "literal" then "#{name}(#{args}) { :blk }"
    when "amp"
      prelude << "blk#{tag} = proc { :blk }"
      "#{name}(#{[args, "&blk#{tag}"].reject(&:empty?).join(", ")})"
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
  # Method local when rebound), or an all-Integer one ahead of the typed one.
  def site_types(row)
    # a literal block given to instance_exec is reached by its one call
    return [row[:type]] if row[:path] == "instance_exec"
    case row[:sites]
    when "one" then [row[:type]]
    when "twice", "rebound" then [row[:type], row[:type]]
    else ["int", row[:type]]
    end
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
    end
    mutate = row[:body] == "mutate"
    if row[:sites] == "rebound" && !METHOD_PATHS.include?(row[:path])
      row = row.merge(sites: "twice")
    end
    real = row.dup
    real[:block] = "none" if BLOCK_PATHS.include?(row[:path])
    ps = params(row, real)
    child = child_level(row[:path], row[:child])
    cps = child_params(child, ps)
    child, cps = "same", ps if cps.nil?
    real[:child] = child
    bare = child != "none"
    pl = param_src(ps)
    cpl = param_src(cps)
    m = "m#{i}"
    # a bare super's call binds the child's parameters first
    sites = site_types(row).each_with_index.map do |type, s|
      tag = "#{i}_#{s}"
      call = args_src(row, bare ? cps : ps, real, type, tag, mutate)
      # a typed value a later key replaces binds nowhere: the call is an
      # Integer one, and says so
      call = args_src(row, bare ? cps : ps, real, "int", tag, false) if type != "int" && real[:type] == "int"
      [tag, *call]
    end
    mutated = mutate ? mutated_param(ps, sites.last[4]) : nil
    return build(i, asked.merge(body: "params")) if mutate && (real[:type] != "string" || mutated.nil?)
    real[:body] = mutate ? "mutate" : "params"
    body = body_src(ps, nil, mutated)
    defs = +""
    uses = +""
    branches = +""
    sites.each_with_index do |(tag, as, prelude, dfs, _), s|
      defs << dfs
      # the locals, written out once the call is built: a block the call
      # passes with `&` joins them
      pre = ->(ind = "") { prelude.map { |l| "#{ind}#{l}\n" }.join }
      # with a grown String, the caller's variable after the call
      out = ->(call) { mutate ? "[#{call}, v#{tag}]" : call }
      case row[:path]
      when "direct", "send", "public_send", "method_call", "method_to_proc", "bind_call", "inherited_cmethod",
           "forward_all", "forward_anon"
        target = case row[:path]
                 when "direct" then m
                 when "send" then "send"
                 when "public_send" then "C#{i}.new.public_send"
                 when "method_call", "method_to_proc"
                   (real[:sites] == "rebound" ? "q#{i}" : "method(:#{m})") +
                     (row[:path] == "method_call" ? ".call" : ".to_proc.call")
                 when "bind_call" then "C#{i}.instance_method(:#{m}).bind_call"
                 when "inherited_cmethod" then "B#{i}.method(:#{m}).call"
                 else "w#{i}"
                 end
        lead = { "send" => ":#{m}", "public_send" => ":#{m}", "bind_call" => "C#{i}.new" }[row[:path]]
        call = call_src(target, lead ? [lead, as].reject(&:empty?).join(", ") : as, row, tag, prelude)
        if real[:sites] == "rebound"
          uses << "q#{i} = #{s.zero? ? "C#{i}.new.method(:#{m})" : "method(:#{m})"}\n"
        end
        uses << pre.call << report(i, out.call(call))
      when "instance", "class_method", "initialize", "define_method"
        recv = { "instance" => "C#{i}.new.#{m}", "class_method" => "C#{i}.#{m}",
                 "initialize" => "C#{i}.new", "define_method" => "C#{i}.new.#{m}" }[row[:path]]
        call = call_src(recv, as, row, tag, prelude)
        call = "(#{call}).v#{i}" if row[:path] == "initialize"
        uses << pre.call << report(i, out.call(call))
      when "raise_new"
        call = "(begin; raise C#{i}, #{as}; rescue C#{i} => j#{tag}; j#{tag}.v#{i}; end)"
        uses << pre.call << report(i, out.call(call))
      when "poly", "class_value"
        recvs = row[:path] == "poly" ? "[A#{i}.new, B#{i}.new]" : "[A#{i}, B#{i}]"
        call = call_src("o#{i}.#{m}", as, row, tag, prelude)
        # the locals are set for each receiver, so each call reads what it
        # did not write itself
        uses << "#{recvs}.each do |o#{i}|\n" << pre.call("  ") << report(i, out.call(call), "  ") << "end\n"
      when "yield_inline"
        uses << pre.call << report(i, out.call("#{m}(#{as}) { |x#{i}| x#{i} }"))
      when "super_explicit", "super_zsuper", "super_include", "super_prepend"
        if bare
          call = call_src("C#{i}.new.#{m}", as, row, tag, prelude)
          uses << pre.call << report(i, out.call(call))
        else
          call = call_src("super", as, row, tag, prelude)
          parent = { "super_explicit" => " < B#{i}", "super_prepend" => " < P#{i}" }[row[:path]]
          incl = row[:path] == "super_include" ? "  include M#{i}\n\n" : ""
          defs << "class C#{tag}#{parent}\n#{incl}  def #{m}\n#{pre.call("    ")}    #{out.call(call)}\n  end\nend\n"
          uses << report(i, "C#{tag}.new.#{m}")
        end
      when "block_yield"
        # one literal block, reached by every site: y<id>(s) yields site s's arguments
        branches << "#{s.zero? ? "  if" : "  elsif"} s#{i} == #{s}\n#{pre.call("    ")}    " \
                    "#{out.call("yield(#{as})")}\n"
      when "proc_call", "lambda_call"
        call = call_src("f#{i}.call", as, row, tag, prelude)
        uses << pre.call << report(i, out.call(call))
      when "instance_exec"
        uses << pre.call << report(i, out.call("Object.new.instance_exec(#{as}) { |#{pl}| #{body} }"))
      when "struct", "struct_kw", "data"
        uses << pre.call << report(i, "S#{i}.new(#{as}).#{row[:path] == "data" ? "to_h" : "to_a"}")
      end
    end
    if row[:path] == "block_yield"
      n = sites.size
      defs << "def y#{i}(s#{i})\n#{branches}  end\nend\n"
      uses << "#{(0...n).to_a.inspect}.each do |s#{i}|\n" <<
        report(i, "y#{i}(s#{i}) { |#{pl}| #{body} }", "  ") << "end\n"
    end
    members = ps.select { |p| %i[req opt post rest kreq kopt].include?(p[0]) }.map { |p| ":#{p[1]}" }
    mod = "module M#{i}\n  def #{m}(#{pl}) = #{body}\nend\n"
    child_src = ->(parent) { "class C#{i}#{parent}\n  def #{m}(#{cpl}) = super\nend\n" }
    head = case row[:path]
           when "direct", "send", "method_call", "method_to_proc"
             # rebound: the Method local's first target, a method of the same parameters
             (real[:sites] == "rebound" ? "class C#{i}\n  def #{m}(#{pl}) = #{body_src(ps, ":c", mutated)}\nend\n" : "") +
               "def #{m}(#{pl}) = #{body}\n"
           when "yield_inline" then "def #{m}(#{pl}) = yield(#{body})\n"
           when "forward_all" then "def #{m}(#{pl}) = #{body}\ndef w#{i}(...) = #{m}(...)\n"
           when "forward_anon" then "def #{m}(#{pl}) = #{body}\ndef w#{i}(*, **, &) = #{m}(*, **, &)\n"
           when "public_send", "instance", "bind_call" then "class C#{i}\n  def #{m}(#{pl}) = #{body}\nend\n"
           when "class_method" then "class C#{i}\n  def self.#{m}(#{pl}) = #{body}\nend\n"
           when "inherited_cmethod"
             "class A#{i}\n  def self.#{m}(#{pl}) = #{body_src(ps, "self", mutated)}\nend\n" \
               "class B#{i} < A#{i}\nend\n"
           when "initialize"
             "class C#{i}\n  attr_reader :v#{i}\n\n  def initialize(#{pl})\n    @v#{i} = #{body}\n  end\nend\n"
           when "raise_new"
             "class C#{i} < StandardError\n  attr_reader :v#{i}\n\n  def initialize(#{pl})\n    @v#{i} = #{body}\n  end\nend\n"
           when "define_method" then "class C#{i}\n  define_method(:#{m}) { |#{pl}| #{body} }\nend\n"
           when "poly"
             "class A#{i}\n  def #{m}(#{pl}) = #{body_src(ps, ":a", mutated)}\nend\n" \
               "class B#{i}\n  def #{m}(#{pl}) = #{body_src(ps, ":b", mutated)}\nend\n"
           when "class_value"
             "class A#{i}\n  def self.#{m}(#{pl}) = #{body_src(ps, ":a", mutated)}\nend\n" \
               "class B#{i}\n  def self.#{m}(#{pl}) = #{body_src(ps, ":b", mutated)}\nend\n"
           when "super_explicit" then "class B#{i}\n  def #{m}(#{pl}) = #{body}\nend\n"
           when "super_zsuper" then "class B#{i}\n  def #{m}(#{pl}) = #{body}\nend\n" + child_src.call(" < B#{i}")
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
    [head + defs + uses, real]
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

  # The cases of `rows`, numbered from `first + 1`.
  def cases(rows, first = 0)
    rows.each_with_index.map { |row, j| render(first + j + 1, row) }
  end

  # The factors where `c` is not at its simplest level, as the probe names a
  # finding's shape.
  def shape(c)
    NAMES.reject { |f| c.realized[f] == SIMPLEST[f] }.map { |f| "#{f}=#{c.realized[f]}" }.join(" ")
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
  args = ARGV.dup
  begin
    until args.empty?
      case args.shift
      when "--strength" then strength = Integer(args.shift)
      when "--random" then random = Integer(args.shift)
      when "--seed" then seed = Integer(args.shift)
      when "--id" then id = Integer(args.shift)
      else raise ArgumentError
      end
    end
    raise ArgumentError unless (1..CallBindingGen::FACTORS.size).cover?(strength) && (random.nil? || random.positive?)
  rescue ArgumentError, TypeError
    abort "usage: ruby tools/call_binding_gen.rb [--strength T | --random N] [--seed S] [--id ID]"
  end
  if random
    cs = CallBindingGen.cases(CallBindingGen.random_rows(random, seed))
    warn "#{cs.size} cases"
  else
    cs, want, got = CallBindingGen.covering_cases(strength, seed)
    warn "#{cs.size} cases, taking #{got} of #{want} #{strength}-way combinations"
  end
  cs = cs.select { |c| c.id == id } if id
  print CallBindingGen.program(cs, true)
end
