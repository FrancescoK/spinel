# Generated builtin-row probes (see tools/builtin_row_probe.rb).
#
#   ruby tools/builtin_row_gen.rb [--strength T | --random N] [--seed S]
#                                 [--ops RE] [--shard I/N] [--id ID]
#   ruby tools/builtin_row_gen.rb --baselines FILE
#
# The builtin methods spinel knows are rows of src/builtin_ops.c (and the
# shared zero-argument rows of src/builtin_zero_ops.inc): a receiver kind, a
# name, a count of arguments, a block form, a result and an emitter. The
# probes that vary how values flow (call binding, value flow, nil
# narrowing) call few of them, with arguments of the type each expects, so
# a row that answers the wrong exception for a surplus option, takes a
# wrong-class argument it should reject, or checks its receiver before it
# runs its arguments goes unseen. This generator calls each row's method
# with the arguments varied instead.
#
# An op is a receiver family (the Ruby class of a row's kind: every Array
# kind is Array), a name and a count of arguments. Its baseline is a call
# CRuby answers without raising, found the way tools/gen_nil_arg_probe.rb
# finds one: the counts the method accepts, then for each count the first
# combination of small sample values (and of the hints a name takes, such
# as :ascii for the case conversions) it answers, on the first of the
# family's sample receivers that answers one. The search runs in a CRuby
# child (`--baselines`), whose answers are kept in build/ keyed by the
# rows and the ruby that found them.
#
# A case is one op and one level of each of FACTORS: the receiver's form
# (typed, read out of a mixed Array, a wrong class or a nil read out of
# one, a nil-or-value local, a value through an RBS-typed identity method,
# and a nil through one), the family's sample receiver, each argument's
# form (typed, read out of a mixed Array, nil, a wrong class, a wrong class
# read out of a mixed Array), the wrong class, the count (the baseline's,
# one more, one less), the block (the baseline's, or the other), whether
# the receiver and each argument are evaluated through a write to a log
# that the case prints after its answer, and --int-overflow=promote. A
# level a case has no place for realizes as the factor's first level. The
# cases of an op cover every pair of levels (covering_cases), except that
# the wrong class only pairs with the argument forms, where it matters.
#
# Each case is a method `brp<id>(k)` called with k = 0 (ARGV.size, so the
# analysis cannot fold it): it prints its answer's inspect, or the class
# and message of what it raised, then the log -- the receiver and the
# arguments in the order they ran, and what the block was given -- so an
# exception of the wrong class, a value, and an operand evaluated out of
# order or skipped each show. Object addresses and the program's own file
# name are normalized away in the program itself.

require "digest"
require "json"
require "prism"
require "rbconfig"
require_relative "probe_common"

module BuiltinRowGen
  ROOT = File.expand_path("..", __dir__)

  FACTORS = [
    # typed: a local of the sample; boxed: read out of a mixed Array;
    # boxed_wrong: a value of another class read out of one (NoMethodError,
    # after the arguments ran); boxed_nil: a nil read out of one; nilable:
    # the sample through `k == 0 ? v : nil`; nilable_nil: the nil through
    # it; rbs / rbs_nil: the sample or a nil through an identity method
    # whose RBS signature takes and answers `T?` (spinel --rbs)
    [:recv, %w[typed boxed boxed_wrong boxed_nil nilable nilable_nil rbs rbs_nil]],
    # which of the family's sample receivers (FAMILIES)
    [:sample, %w[s0 s1 s2 s3]],
    # each argument: its baseline value, read out of a mixed Array, nil, a
    # value of the wrong class (wval), that read out of a mixed Array
    [:a0, %w[typed boxed nil wrong boxed_wrong]],
    [:a1, %w[typed boxed nil wrong boxed_wrong]],
    [:a2, %w[typed boxed nil wrong boxed_wrong]],
    # the wrong class an argument at `wrong` takes; one of the baseline's
    # own class takes the next
    [:wval, %w[str int float sym array hash complex rational]],
    # the baseline's count, one argument more (a copy of the last), one less
    [:count, %w[exact extra missing]],
    # the baseline's block form, or the other: a block where it had none,
    # none where it had one
    [:block, %w[base other]],
    # log: the receiver and each argument written as `(log << :a0; a0)`
    [:wrap, %w[none log]],
    [:mode, %w[default promote]],
  ].freeze
  # The op is a factor a case never steps away from (probe_common's FIXED):
  # a finding reduces toward the simplest levels of the others.
  NAMES = (FACTORS.map(&:first) + [:op]).freeze
  FIXED = [:op].freeze
  SIMPLEST = FACTORS.to_h { |f, l| [f, l[0]] }.merge(op: nil).freeze
  WVALS = {
    "str" => ['+"s"', String], "int" => ["7", Integer], "float" => ["1.5", Float], "sym" => [":s", Symbol],
    "array" => ["[7]", Array], "hash" => ["{7 => 8}", Hash], "complex" => ["Complex(1, 1)", Complex],
    "rational" => ["Rational(1, 2)", Rational],
  }.freeze

  # The receiver families: the kinds of src/builtin_ops.c each serves, and
  # its sample receivers as Ruby text with the RBS type of the identity
  # method the rbs levels read them through (nil: none). TY_POLY's rows are
  # the boxed faces of String's and Symbol's; BOP_IVAR_LESS's, reflection on
  # any value without instance variables. A kind no family serves (Thread,
  # Fiber, ConditionVariable, Process::Status and ::Tms, Addrinfo,
  # Socket::Option: values a case cannot make without side effects of its
  # own) is listed as unprobed.
  FAMILIES = {
    "Integer" => [%w[TY_INT BOP_IVAR_LESS], [["7", "Integer"], ["-3", "Integer"]]],
    "Float" => [%w[TY_FLOAT], [["0.3", "Float"], ["-2.5", "Float"]]],
    "Rational" => [%w[TY_RATIONAL], [["Rational(3, 4)", "Rational"], ["Rational(-5, 2)", "Rational"]]],
    "Complex" => [%w[TY_COMPLEX], [["Complex(1, 2)", "Complex"], ["Complex(0.5, -1.5)", "Complex"]]],
    "String" => [%w[TY_STRING TY_POLY BOP_IVAR_LESS], [['+"ab"', "String"], ['+"Hello World"', "String"]]],
    "Symbol" => [%w[TY_SYMBOL TY_POLY], [[":ab", "Symbol"], [":Hello", "Symbol"]]],
    "Array" => [%w[BOP_ANY_ARRAY], [["[1, 2, 3]", "Array[Integer]"], ["[[1, 2], [3, 4]]", "Array[Array[Integer]]"],
                                    ['[+"a", +"b"]', "Array[String]"], ["[1.5, 2.5]", "Array[Float]"]]],
    "Hash" => [%w[BOP_ANY_HASH], [["{1 => 2, 3 => 4}", "Hash[Integer, Integer]"],
                                  ['{"a" => 1, "b" => 2}', "Hash[String, Integer]"],
                                  ["{a: 1, b: 2}", "Hash[Symbol, Integer]"],
                                  ['{"a" => +"x"}', "Hash[String, String]"]]],
    "Range" => [%w[TY_RANGE], [["(1..3)", "Range[Integer]"], ["(1...4)", "Range[Integer]"]]],
    "Range(Float)" => [%w[TY_FLOAT_RANGE], [["(0.5..2.5)", "Range[Float]"], ["(0.5...3.0)", "Range[Float]"]]],
    "Range(String)" => [%w[TY_STR_RANGE], [['("a".."c")', "Range[String]"], ['("a"..."d")', "Range[String]"]]],
    "Time" => [%w[TY_TIME], [["Time.at(0).utc", "Time"], ["Time.utc(2000, 1, 2, 3, 4, 5)", "Time"]]],
    "MatchData" => [%w[TY_MATCHDATA], [['/(a)(b)?/.match("xab")', nil], ['/(?<x>a)(?<y>b)/.match("ab")', nil]]],
    "Regexp" => [%w[TY_REGEX], [["/a(b)?/", "Regexp"], ["/(?<n>x)y/i", "Regexp"]]],
    "Random" => [%w[TY_RANDOM], [["Random.new(42)", "Random"]]],
    "Enumerator" => [%w[TY_ENUMERATOR], [["[1, 2, 3].each", nil], ["(1..4).each_slice(2)", nil]]],
    "Proc" => [%w[TY_PROC], [["proc { |x, y| [x, y] }", nil], ["lambda { |x| x }", nil]]],
    "Method" => [%w[TY_METHOD], [["1.method(:+)", nil]]],
    "File" => [%w[TY_IO], [["brp_file(ID)", "File"]]],
    "Queue" => [%w[TY_QUEUE], [["brp_queue", nil]]],
    "Mutex" => [%w[TY_MUTEX], [["Mutex.new", nil]]],
    "Exception" => [%w[TY_EXCEPTION], [["brp_key_error", nil], ["brp_no_method_error", nil],
                                       ["SystemExit.new(3, +\"bye\")", nil], ["brp_stop_iteration", nil]]],
  }.freeze
  # The helpers a sample calls, defined above the cases that use one.
  HELPERS = {
    "brp_file" => <<~'RUBY',
      def brp_file(n)
        path = File.join(Dir.tmpdir, "brp_#{n}.txt")
        # a run before this one may have left it read-only (File#chmod)
        File.delete(path) if File.exist?(path)
        File.write(path, "ab\ncd\n")
        File.open(path, "r+")
      end
    RUBY
    "brp_queue" => <<~'RUBY',
      def brp_queue
        q = Queue.new
        q.push(1)
        q.push(2)
        q
      end
    RUBY
    "brp_key_error" => <<~'RUBY',
      def brp_key_error
        {}.fetch(:x)
      rescue KeyError => e
        e
      end
    RUBY
    "brp_no_method_error" => <<~'RUBY',
      def brp_no_method_error
        nil.brp_none(1)
      rescue NoMethodError => e
        e
      end
    RUBY
    "brp_stop_iteration" => <<~'RUBY',
      def brp_stop_iteration
        [].each.next
      rescue StopIteration => e
        e
      end
    RUBY
  }.freeze

  # The values a baseline's arguments are searched among, simplest first,
  # after the name's own HINTS.
  SAMPLES = ["1", '+"a"', ":a", "[1]", "{1 => 2}", "0.5", "2", "(0..1)", "/a/", "true", "nil"].freeze
  HINTS = {
    %w[upcase downcase capitalize swapcase upcase! downcase! capitalize! swapcase!] => [":ascii", ":turkic", ":lithuanian"],
    %w[encode encode! force_encoding] => ['+"UTF-8"', '+"ASCII-8BIT"'],
    %w[pack unpack] => ['+"C*"'],
    %w[strftime] => ['+"%Y-%m-%d"'],
    %w[crypt] => ['+"ab"'],
    %w[instance_variable_get instance_variable_defined? instance_variable_set] => [":@a"],
    %w[rationalize] => ["Rational(1, 100)", "0.01"],
    %w[localtime getlocal] => ['+"+09:00"'],
    %w[chmod] => ["0o644"],
    %w[advise] => [":normal"],
    %w[lineno= seek pos= truncate pread ungetbyte getbyte] => ["0"],
    %w[step upto downto] => ["5"],
  }.flat_map { |names, v| names.map { |n| [n, v] } }.to_h.freeze
  # Names whose answer is not the same in two runs (an object's identity,
  # a file's inode, times, descriptor numbers), or that wait.
  SKIP = %w[hash object_id __id__ sleep wait wait_readable wait_writable wait_priority fileno to_i ino dev rdev
            blksize blocks nlink uid gid stat lstat mtime atime ctime birthtime reopen chown fcntl ioctl
            close_on_exec= autoclose= pid source_location].freeze
  # Names skipped for one family only: File's to_i is its descriptor (every
  # other family's to_i is a value), and Random's draws come from another
  # generator than CRuby's on purpose (test/i898.rb), so a seed answers
  # other numbers.
  SKIP_ONLY = { "to_i" => "File", "fileno" => "File", "ctime" => "File", "rand" => "Random",
                "bytes" => "Random" }.freeze

  # The rows: kind, name, argc_min, argc_max (127: any), block form and the
  # line of src/builtin_ops.c (or builtin_zero_ops.inc) that holds it.
  Row = Struct.new(:kind, :name, :min, :max, :block, :at)

  Case = ProbeCommon::Covering::Case
  class GeneratorError < StandardError; end

  extend ProbeCommon::Covering

  module_function

  def rows
    @rows ||= begin
      path = File.join(ROOT, "src/builtin_ops.c")
      src = File.read(path)
      start = src.index("static const BuiltinOp bop_rows[] = {") or raise GeneratorError, "no bop_rows in #{path}"
      stop = src.index("\n};", start)
      out = []
      line0 = src[0, start].count("\n") + 1
      src[start...stop].scan(/\{\s*(\w+),\s*"((?:[^"\\]|\\.)*)",\s*(-?\w+),\s*(-?\w+),\s*(BF_\w+)/) do
        m = Regexp.last_match
        out << Row.new(m[1], m[2].gsub(/\\(.)/, '\1'), count(m[3]), count(m[4]), m[5],
                       "builtin_ops.c:#{line0 + src[start, m.begin(0)].count("\n")}")
      end
      inc = File.join(ROOT, "src/builtin_zero_ops.inc")
      File.foreach(inc).with_index(1) do |l, n|
        if (m = l.match(/\ABZ_IO\("([^"]+)",\s*\w+,\s*\w+,\s*(\d+)/))
          out << Row.new("TY_IO", m[1], 0, m[2].to_i, "BF_ANY", "builtin_zero_ops.inc:#{n}")
        elsif (m = l.match(/\ABZ_STR\("([^"]+)",\s*\w+,\s*\w+,\s*(\d+),\s*(\w+)/))
          out << Row.new("TY_STRING", m[1], 0, m[2].to_i, m[3], "builtin_zero_ops.inc:#{n}")
        end
      end
      raise GeneratorError, "no rows parsed" if out.size < 100
      out
    end
  end

  def count(s)
    s == "BOP_ARGC_ANY" ? 127 : Integer(s)
  end

  # The families serving `kind`.
  def families_of(kind)
    FAMILIES.select { |_, (kinds, _)| kinds.include?(kind) }.keys
  end

  # [family, name] for every row a family serves, in table order.
  def method_list
    rows.flat_map { |r| families_of(r.kind).map { |f| [f, r.name] } }.uniq
  end

  def skip?(family, name)
    return SKIP_ONLY[name] == family if SKIP_ONLY.key?(name)
    SKIP.include?(name)
  end

  # The baselines file, keyed by the rows, this generator and the ruby that
  # searched them.
  def baselines_path
    key = Digest::SHA256.hexdigest([File.read(File.join(ROOT, "src/builtin_ops.c")),
                                    File.read(File.join(ROOT, "src/builtin_zero_ops.inc")),
                                    File.read(__FILE__), RUBY_DESCRIPTION].join("\0"))[0, 16]
    File.join(ROOT, "build", "builtin-row-probe-baselines", "#{key}.json")
  end

  # { "Family#name" => { "n" => {"args" => [...], "block" => bool, "sample" => i} } },
  # searched once in a CRuby child and kept.
  def baselines
    @baselines ||= begin
      path = baselines_path
      unless File.exist?(path)
        FileUtils.mkdir_p(File.dirname(path))
        warn "builtin_row_gen: searching CRuby baselines (once per table) -> #{path}"
        # shards started together each search; the last rename wins
        tmp = "#{path}.#{Process.pid}.tmp"
        ok = system(RbConfig.ruby, "-W0", __FILE__, "--baselines", tmp)
        raise GeneratorError, "the baseline search failed" unless ok && File.exist?(tmp)
        File.rename(tmp, path)
      end
      JSON.parse(File.read(path))
    end
  end

  # The ops: [family, name, n] with a baseline, filtered by `re` (matched
  # against "Family#name/n") and sharded.
  def ops(re = nil, shard = nil)
    b = baselines
    all = method_list.flat_map do |fam, name|
      (b["#{fam}##{name}"] || {}).keys.sort.map { |n| "#{fam}##{name}/#{n}" }
    end.uniq
    all = all.grep(re) if re
    all = all.each_with_index.select { |_, i| i % shard[1] == shard[0] }.map(&:first) if shard
    all
  end

  def op_parts(op)
    m = op.match(%r{\A(.+?)#(.+)/(\d+)\z}) or raise GeneratorError, "bad op #{op.inspect}"
    [m[1], m[2], m[3].to_i]
  end

  def baseline(op)
    fam, name, n = op_parts(op)
    baselines.fetch("#{fam}##{name}").fetch(n.to_s)
  end

  def samples(fam)
    FAMILIES.fetch(fam)[1]
  end

  # RBS identity helpers, one per type: `brp_rbs_<tag>`.
  def rbs_tag(t)
    t.downcase.gsub(/[^a-z0-9]+/, "_").sub(/_+\z/, "")
  end

  def rbs_types
    FAMILIES.values.flat_map { |_, ss| ss.map(&:last) }.compact.uniq
  end

  # The RBS directory every rbs case compiles with: one signature per
  # identity helper, written once.
  def rbs_dir
    @rbs_dir ||= begin
      dir = File.join(ROOT, "build", "builtin-row-probe-rbs")
      text = "class Object\n" + rbs_types.map { |t| "  def brp_rbs_#{rbs_tag(t)}: (#{t}?) -> #{t}?\n" }.join + "end\n"
      path = File.join(dir, "brp.rbs")
      unless File.exist?(path) && File.read(path) == text
        FileUtils.mkdir_p(dir)
        File.write(path, text)
      end
      dir
    end
  end

  # ---- cases ---------------------------------------------------------------

  # The levels a case of `op` can take, by factor.
  def levels_for(op)
    fam, name, n = op_parts(op)
    ss = samples(fam)
    # a setter is called as one (`r.lineno = a0`): one argument, no block
    setter = name.match?(/\A[a-z_]\w*=\z/)
    FACTORS.to_h do |f, levels|
      ls = case f
           when :recv then ss.any?(&:last) ? levels : levels - %w[rbs rbs_nil]
           when :sample then levels.first(ss.size)
           when :a0, :a1, :a2 then f.to_s[1].to_i < n ? levels : [levels[0]]
           when :wval then n.positive? ? levels : [levels[0]]
           when :count then setter ? [levels[0]] : n.positive? ? levels : levels - ["missing"]
           when :block then setter ? [levels[0]] : levels
           else levels
           end
      [f, ls]
    end
  end

  # A module that covers one shape of op's levels (Covering over them).
  def shape_gen(levels)
    @shape_gens ||= {}
    @shape_gens[levels] ||= begin
      m = Module.new
      m.const_set(:FACTORS, levels.to_a.freeze)
      m.const_set(:NAMES, levels.keys.freeze)
      m.extend(ProbeCommon::Covering)
      m
    end
  end

  # The rows covering every `t`-way combination of `levels`, except those
  # that take the wrong class without an argument (it only matters there).
  def shape_rows(levels, t, seed)
    @shape_rows ||= {}
    @shape_rows[[levels, t, seed]] ||= begin
      want = shape_tuples(levels, t)
      [shape_gen(levels).covering_array(t, seed, 5, want), want]
    end
  end

  # The combinations of `levels` a case can take: the wrong class only
  # beside an argument at a wrong level, and no form for the argument one
  # less drops.
  def shape_tuples(levels, t)
    g = shape_gen(levels)
    names = g::NAMES
    last = %i[a0 a1 a2].select { |a| levels[a].size > 1 }.last
    combos = (0...names.size).to_a.combination(t).to_a
    g.all_tuples(t).reject do |kk, _|
      ti, ls = g.unkey(kk, t)
      lv = combos[ti].each_with_index.to_h { |f, x| [names[f], levels[names[f]][ls[x]]] }
      args = lv.slice(:a0, :a1, :a2)
      (t > 1 && lv.key?(:wval) && (args.empty? || args.values.none? { |l| l.include?("wrong") })) ||
        (lv[:count] == "missing" && last && lv.key?(last) && lv[last] != "typed")
    end
  end

  # Each op's cases, from the rows covering its shape. Answers the cases,
  # how many combinations of levels the ops ask for and how many the cases
  # take (a level a case has no place for realizes as another, so a few are
  # not taken); with `only`, those that agree with it.
  def covering_cases(t, seed, _tries = 100, only = {})
    cases = []
    want = got = 0
    @ops_sel ||= [nil, nil]
    ops(*@ops_sel).each do |op|
      levels = levels_for(op)
      tt = [t, levels.size].min
      rows, tuples = shape_rows(levels, tt, seed)
      seen = {}
      mine = rows.filter_map do |row|
        c = render(cases.size + seen.size + 1, SIMPLEST.merge(row).merge(only).merge(op: op))
        next if seen[c.realized] || only.any? { |f, l| c.realized[f] != l }
        seen[c.realized] = c
      end
      g = shape_gen(levels)
      names = g::NAMES
      combos = (0...names.size).to_a.combination(tt).to_a
      asked = tuples.keys.reject do |kk|
        ti, ls = g.unkey(kk, tt)
        combos[ti].each_with_index.any? { |f, x| only.key?(names[f]) && levels[names[f]][ls[x]] != only[names[f]] }
      end
      took = g.tuples_of(mine, tt)
      want += asked.size
      got += asked.count { |kk| took.key?(kk) }
      cases.concat(mine)
    end
    raise ArgumentError, "no op matches" if cases.empty?
    [cases, want, got]
  end

  # Sets the ops the next covering_cases / random_rows take.
  def choose_ops(re, shard)
    @ops_sel = [re, shard]
  end

  def random_rows(n, seed)
    rng = Random.new(seed)
    all = ops(*(@ops_sel || [nil, nil]))
    Array.new(n) do
      op = all[rng.rand(all.size)]
      levels_for(op).to_h { |f, l| [f, l[rng.rand(l.size)]] }.merge(op: op)
    end
  end

  def render(id, row)
    src, real = build(id, row)
    again, = build(id, real)
    raise GeneratorError, "case #{id} does not render back from its realized levels" unless again == src
    raise GeneratorError, "case #{id} (#{real[:op]}) does not parse" unless Prism.parse(src).errors.empty?
    Case.new(id, real, src)
  end

  # A value of another class than the baseline argument `base`'s, for the
  # wrong level `wval`.
  def wrong_value(wval, base)
    cls = baseline_class(base)
    keys = WVALS.keys
    i = keys.index(wval)
    keys.size.times do |j|
      code, k = WVALS[keys[(i + j) % keys.size]]
      return code unless cls && cls <= k
    end
  end

  # The class of a baseline argument's text, as far as the forms care.
  def baseline_class(code)
    case code
    when /\A[+-]?\d+\z/, /\A0o\d+\z/ then Integer
    when /\A[+-]?\d+\.\d+\z/ then Float
    when /\A\+?"/ then String
    when /\A:/ then Symbol
    when /\A\[/ then Array
    when /\A\{/ then Hash
    when /\AComplex/ then Complex
    when /\ARational/ then Rational
    end
  end

  # A value of another class to mix `code` with in an Array, so the read is
  # boxed.
  def companion(code)
    baseline_class(code) == Symbol ? "7" : ":brp"
  end

  BINARY = %w[+ - * / % ** == != < > <= >= <=> === =~ !~ & | ^ << >>].freeze
  UNARY = { "-@" => "-", "+@" => "+", "~" => "~", "!" => "!" }.freeze

  # The case's source and the levels it realized.
  def build(id, row)
    op = row[:op]
    fam, name, n = op_parts(op)
    base = baseline(op)
    real = SIMPLEST.merge(row.slice(*NAMES))
    lv = levels_for(op)
    lv.each { |f, ls| real[f] = SIMPLEST[f] unless ls.include?(real[f]) }
    ss = samples(fam)
    sample = ss[real[:sample][1].to_i] || ss[0]
    real[:sample] = "s0" unless ss[real[:sample][1].to_i]
    real[:recv] = "typed" if real[:recv].start_with?("rbs") && sample[1].nil?
    args = base["args"].dup
    count = real[:count]
    # the slots the count leaves, each with its form
    forms = %i[a0 a1 a2].first(n).map { |a| real[a] }
    if count == "missing"
      args.pop
      real[%i[a0 a1 a2][n - 1]] = "typed"
      forms.pop
    elsif count == "extra"
      args << (args.last || "1")
      forms << "typed"
    end
    real[:wval] = "str" unless forms.any? { |f| f.include?("wrong") }
    with_block = base["block"] ^ (real[:block] == "other")
    log = real[:wrap] == "log"
    recv_code = sample[0].sub("ID", id.to_s)
    body = []
    body << "log = []"
    body << "r = " + recv_form(real[:recv], recv_code, fam, sample[1])
    args.each_with_index do |a, i|
      body << "a#{i} = " + arg_form(forms[i], a, real[:wval])
    end
    rr = log ? "(log << :r; r)" : "r"
    as = args.each_index.map { |i| log ? "(log << :a#{i}; a#{i})" : "a#{i}" }
    blk = with_block ? " { |*b| log << b; break :brp_cut if log.size > 20; b[0] }" : ""
    call = if !with_block && args.size == 1 && BINARY.include?(name)
             "#{rr} #{name} #{as[0]}"
           elsif !with_block && args.empty? && UNARY.key?(name)
             "#{UNARY[name]}#{rr}"
           elsif !with_block && name == "[]"
             "#{rr}[#{as.join(", ")}]"
           elsif !with_block && name == "[]=" && args.size >= 1
             "(#{rr}[#{as[0...-1].join(", ")}] = #{as[-1]})"
           elsif !with_block && args.size == 1 && name.match?(/\A[a-z_]\w*=\z/)
             "(#{rr}.#{name[0...-1]} = #{as[0]})"
           else
             "#{rr}.#{name}#{args.empty? ? "" : "(#{as.join(", ")})"}#{blk}"
           end
    body << "begin"
    body << "  x = #{call}"
    body << "  puts \"#{id} \" + (x.is_a?(Enumerator) ? \"#<Enumerator>\" : brp_norm(x.inspect))"
    body << "rescue StandardError, NotImplementedError => e"
    body << "  puts \"#{id} \" + e.class.to_s + \": \" + brp_norm(e.message)"
    body << "end"
    body << "puts \"#{id} log \" + brp_norm(log.inspect)"
    src = "def brp#{id}(k)\n" + body.map { |l| "  #{l}\n" }.join + "end\nbrp#{id}(ARGV.size)\n"
    real[:op] = op
    [src, real]
  end

  def recv_form(form, code, fam, rbs)
    wrong = fam == "Integer" ? '+"s"' : "7"
    case form
    when "typed" then code
    when "boxed" then "[#{code}, #{companion(code)}][k]"
    when "boxed_wrong" then "[#{wrong}, #{code}][k]"
    when "boxed_nil" then "[nil, #{code}][k]"
    when "nilable" then "k == 0 ? #{code} : nil"
    when "nilable_nil" then "k == 0 ? nil : #{code}"
    when "rbs" then "brp_rbs_#{rbs_tag(rbs)}(k == 0 ? #{code} : nil)"
    when "rbs_nil" then "brp_rbs_#{rbs_tag(rbs)}(k == 0 ? nil : #{code})"
    else raise GeneratorError, "no receiver form #{form}"
    end
  end

  def arg_form(form, code, wval)
    case form
    when "typed" then code
    when "boxed" then "[#{code}, #{companion(code)}][k]"
    when "nil" then "nil"
    when "wrong" then wrong_value(wval, code)
    when "boxed_wrong" then "[#{wrong_value(wval, code)}, #{code}][k]"
    else raise GeneratorError, "no argument form #{form}"
    end
  end

  def flags(cases)
    fl = cases.map { |c| case_flags(c) }.uniq
    raise GeneratorError, "the cases of one program take one set of flags" unless fl.size == 1
    fl[0]
  end

  def case_flags(c)
    f = []
    f << "--int-overflow=promote" if c.realized[:mode] == "promote"
    f += ["--rbs", rbs_dir] if c.realized[:recv].start_with?("rbs")
    f
  end

  # The helpers the cases call, then the cases.
  def program(cases, any_mode = false)
    srcs = cases.map(&:src).join
    pre = +"# frozen_string_literal: true\n"
    fl = any_mode ? [] : flags(cases)
    pre << "# spinel #{fl.join(" ")}\n" unless fl.empty?
    pre << "require \"tmpdir\"\n" if srcs.include?("brp_file(")
    pre << "def brp_norm(s)\n  s.gsub(/0x\\h+/, \"0x\").gsub(/[^\\s\"'(\\[]*(?:ref|sp)_\\d+\\.rb/, \"FILE.rb\")\nend\n"
    HELPERS.each { |h, text| pre << text if srcs.include?("#{h}(") || srcs.match?(/\b#{h}\b/) }
    rbs_types.each do |t|
      tag = rbs_tag(t)
      pre << "def brp_rbs_#{tag}(x) = x\n" if srcs.include?("brp_rbs_#{tag}(")
    end
    src = pre + cases.map { |c| "# case #{c.id}: #{shape(c)}\n" + c.src }.join
    raise GeneratorError, "a generated program does not parse" unless Prism.parse(src).errors.empty?
    src
  end

  # The op, then the factors a case does not take at their simplest.
  def shape(c)
    rest = FACTORS.map(&:first).reject { |f| c.realized[f] == SIMPLEST[f] }.map { |f| "#{f}=#{c.realized[f]}" }
    ([c.realized[:op]] + rest).join(" ")
  end

  # The answer line, then the log: a difference in the log is the order the
  # operands ran in (or one skipped), or what the block was given.
  def diff_kind(want, got, _c)
    if (k = ProbeCommon.count_kind(want, got))
      return k
    end
    at = (0...want.size).find { |i| !ProbeCommon.same_answer?(want[i], got[i]) }
    return "exit-status" if at.nil?
    return "log" if want[at].start_with?("log ")
    ProbeCommon.answer_kind(want[at], got[at], "value")
  end

  # ---- the CRuby baseline search (--baselines) --------------------------------

  module Search
    module_function

    def run(out)
      require "timeout"
      require "tmpdir"
      require "fileutils"
      Warning[:deprecated] = false
      Warning[:experimental] = false
      report = {}
      Dir.mktmpdir("brp-baselines") do |dir|
        Dir.chdir(dir) do
          ENV["TMPDIR"] = dir
          # the helpers the samples call, as the programs define them
          TOPLEVEL_BINDING.eval(HELPERS.values.join)
          BuiltinRowGen.method_list.each do |fam, name|
            next if BuiltinRowGen.skip?(fam, name)
            r = search(fam, name)
            report["#{fam}##{name}"] = r unless r.empty?
          end
        end
      end
      File.write(out, JSON.pretty_generate(report))
      warn "builtin_row_gen: #{report.size} methods have a baseline, #{report.sum { |_, v| v.size }} counts"
    end

    def block_proc(log)
      proc do |*b|
        log << b
        break :brp_cut if log.size > 20
        b[0]
      end
    end

    # [:ok, inspect] or the exception.
    def attempt(code, name, args, with_block)
      log = []
      recv = TOPLEVEL_BINDING.eval(code.sub("ID", "0"))
      vals = args.map { |a| TOPLEVEL_BINDING.eval(a) }
      res = Timeout.timeout(1) do
        with_block ? recv.__send__(name, *vals, &block_proc(log)) : recv.__send__(name, *vals)
      end
      [:ok, res.is_a?(Enumerator) ? "#<Enumerator>" : norm(res.inspect), res.is_a?(Enumerator)]
    rescue Exception => e # rubocop:disable Lint/RescueException
      raise if e.is_a?(Interrupt)
      e
    end

    def norm(s)
      s.gsub(/0x\h+/, "0x")
    end

    def search(fam, name)
      out = {}
      ss = BuiltinRowGen.samples(fam)
      return out unless ss.any? { |code, _| (TOPLEVEL_BINDING.eval(code.sub("ID", "0")).respond_to?(name) rescue false) }
      hint = HINTS.fetch(name, [])
      pool = (hint + SAMPLES).uniq
      (0..3).each do |n|
        ss.each_with_index do |(code, _), si|
          found = find(code, name, n, pool)
          next unless found
          args, with_block = found
          # the same answer twice: no identity, time or randomness in it
          a = attempt(code, name, args, with_block)
          b = attempt(code, name, args, with_block)
          next unless a.is_a?(Array) && b.is_a?(Array) && a[1] == b[1]
          out[n.to_s] = { "args" => args, "block" => with_block, "sample" => si }
          break
        end
      end
      out
    end

    # The first combination of `n` values of `pool` the method answers, and
    # whether it takes the block: a call that answers an Enumerator, or asks
    # for a block, is made with one.
    def find(code, name, n, pool)
      probe = attempt(code, name, Array.new(n, "nil"), false)
      return nil if probe.is_a?(ArgumentError) && probe.message.include?("wrong number of arguments")
      pool.repeated_permutation(n) do |args|
        r = attempt(code, name, args, false)
        if r.is_a?(Array)
          return [args, false] unless r[2]
          rb = attempt(code, name, args, true)
          return [args, true] if rb.is_a?(Array)
        elsif r.is_a?(LocalJumpError) || r.message.to_s.include?("no block given")
          rb = attempt(code, name, args, true)
          return [args, true] if rb.is_a?(Array)
        end
      end
      nil
    end
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV[0] == "--baselines"
    BuiltinRowGen::Search.run(ARGV.fetch(1))
    exit 0
  end
  strength = 2
  random = nil
  seed = 1
  id = nil
  re = nil
  shard = nil
  args = ARGV.dup
  begin
    until args.empty?
      case args.shift
      when "--strength" then strength = Integer(args.shift)
      when "--random" then random = Integer(args.shift)
      when "--seed" then seed = Integer(args.shift)
      when "--id" then id = Integer(args.shift)
      when "--ops" then re = Regexp.new(args.shift.to_s)
      when "--shard" then shard = args.shift.to_s.split("/").map { |x| Integer(x) }
      else raise ArgumentError
      end
    end
  rescue ArgumentError, TypeError => e
    warn e.message unless e.message == "ArgumentError"
    abort "usage: ruby tools/builtin_row_gen.rb [--strength T | --random N] [--seed S] [--ops RE] [--shard I/N] " \
          "[--id ID] | --baselines FILE"
  end
  BuiltinRowGen.choose_ops(re, shard)
  if random
    cs = BuiltinRowGen.cases(BuiltinRowGen.random_rows(random, seed))
    warn "#{cs.size} cases"
  else
    cs, want, got = BuiltinRowGen.covering_cases(strength, seed)
    warn "#{cs.size} cases, taking #{got} of #{want} #{strength}-way combinations of their ops' levels"
  end
  cs = cs.select { |c| c.id == id } if id
  cs.group_by { |c| BuiltinRowGen.case_flags(c) }.each_value { |g| print BuiltinRowGen.program(g, true) }
end
