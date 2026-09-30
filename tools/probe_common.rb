# The runner the generated-case probes share (tools/call_binding_probe.rb,
# tools/value_flow_probe.rb): a covering array of a generator's factors, the
# cases run in batches under CRuby and under spinel, the differences split to
# the case that carries them, confirmed alone, reduced and reported.
#
# A generator is a module answering FACTORS ([name, levels] pairs, the first
# level of each its simplest), NAMES, SIMPLEST, GeneratorError, render(id, row) (a Case of the levels it realized, which render
# back to the same program), covering_cases(t, seed, tries, only), cases(rows),
# pinned_cases(rows, only), pins(spec),
# random_rows(n, seed), program(cases), flags(cases) and shape(case), and
# optionally diff_kind(want, got, case). A probe names, beside it, the lines CRuby
# prints when a generated program reads a name it does not define. Covering gives a generator all but render,
# program, flags and shape from its FACTORS.
#
# A program spinel refuses, whose C does not build, that crashes or that runs
# out of time is split in halves until one case carries the failure; a
# difference seen in a program is confirmed on its case alone. A failure no
# single case carries (two cases that only fail together) is kept as an
# `interaction`, with the program that showed it.
#
# Each finding is then reduced: one factor at a time steps toward its
# simplest level for as long as the case alone still makes the same kind of
# difference. The findings of a run are reduced simplest first, a few at a
# time; a finding that makes the same kind of difference as one reduced
# before it and takes every level that one still needs is taken to be that
# bug again and is not reduced itself -- it is listed under that finding's
# shape, its own program kept apart (DIR/<label>/absorbed/). That shortcut is
# a judgement, not a proof, and the summary says how many findings it
# absorbed. A reduction that runs out of steps says so.
#
# What counts as a finding follows the compiler's own contract. Ruby that
# does not parse is no case. An exception CRuby raises is part of the
# expected answer: spinel has to raise the same one. Spinel may refuse a
# program at compile time, naming the construct ("unsupported ...") rather
# than compile it wrong -- docs/limitations.md counts that a gap -- so a
# refusal (label compile-error) is reported in the `refused` tier. A
# difference docs/limitations.md describes as the answer on purpose (a
# probe's DOCUMENTED list) is reported in the `documented` tier, citing it.
# Everything else that differs is `wrong`: another answer, exception, order of
# evaluation or exit status (output-diff), C that does not build (link-error:
# the compiler should have refused), a compiler that fails without naming a
# construct (compiler-failure), a crash, a timeout, an interaction.
#
# Output, under DIR (the tool writes only its own files there, will not take
# a directory holding others, and runs one at a time in it): summary.txt
# (coverage, findings by tier and label, the failure rate of every factor
# level, the findings in families by the difference they make and in shapes
# by the factors they need) and <label>/case_<id>.rb, each finding's reduced
# case as a program of its own, with CRuby's answer and spinel's in a comment
# above it.
#
# Exit status: 0 no wrong answer, 1 a wrong answer, 4 the tool's own error.
# (A run is many programs, so unlike `spinel diff` one status summarizes it.)

require "fileutils"
require "rbconfig"
require "tmpdir"

module ProbeCommon
  WRONG = %w[output-diff link-error compiler-failure crash timeout interaction].freeze
  LABELS = (WRONG + %w[compile-error]).freeze
  # A compiler diagnostic's location, which moves as a case shrinks.
  LOCATION = /\A\S+\.(?:rb|c|h):\d+(?::\d+)?: /

  Outcome = Struct.new(:label, :detail, :lines, :status, :stderr)
  Finding = Struct.new(:c, :label, :detail, :want, :got, :kind, :program, :absorbed, :stopped, :name) do
    # the file a finding is written to: its case's, or an interaction's own
    def file = name || "case_#{c.id}"
  end

  # The covering array of a generator's FACTORS, for a generator module to
  # extend: it calls the generator's render.
  module Covering
    Case = Struct.new(:id, :realized, :src)

    # Rows covering every `t`-way combination of levels of FACTORS in
    # `uncovered` (all of them when nil), by AETG's greedy construction: each
    # row is the best of a few candidates, each candidate built factor by
    # factor in a random order, each factor taking the level that covers the
    # most combinations not yet covered with the factors already set.
    def covering_array(t, seed, candidates = 5, uncovered = nil)
      rng = Random.new(seed)
      k = self::FACTORS.size
      sizes = self::FACTORS.map { |_, l| l.size }
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
      rows.map { |r| self::NAMES.each_with_index.to_h { |f, i| [f, self::FACTORS[i][1][r[i]]] } }
    end

    # Every `t`-way combination of levels, as the keys covering_array uses.
    def all_tuples(t)
      sizes = self::FACTORS.map { |_, l| l.size }
      h = {}
      (0...self::FACTORS.size).to_a.combination(t).each_with_index do |tu, i|
        tu.map { |f| (0...sizes[f]).to_a }.reduce([[]]) { |acc, ls| acc.product(ls).map { |a, l| a + [l] } }.each do |ls|
          h[key(i, ls)] = true
        end
      end
      h
    end

    # The `t`-way combinations the realized levels of `cases` take.
    def tuples_of(cases, t)
      idx = self::FACTORS.map { |_, l| l.each_with_index.to_h }
      combos = (0...self::FACTORS.size).to_a.combination(t).to_a
      h = {}
      cases.each do |c|
        lv = self::NAMES.each_with_index.map { |f, i| idx[i][c.realized[f]] }
        combos.each_with_index { |tu, i| h[key(i, tu.map { |f| lv[f] })] = true }
      end
      h
    end

    # Cases for every `t`-way combination some case takes. The covering
    # array's rows ask for levels; a combination they asked for and no case
    # took is then tried from up to `tries` rows with its levels fixed --
    # random ones, and the realized levels of the cases that take the most of
    # them -- and the first case that takes it joins. Smaller combinations go
    # first, and a combination is tried only when every one of its parts is
    # taken. Answers the cases, how many combinations there are, and how many
    # the cases take.
    #
    # With `only`, every case takes its levels (see pinned_cases), and the
    # combinations are those that agree with them.
    def covering_cases(t, seed, tries = 100, only = {})
      cases = pinned_cases(covering_array(t, seed), only)
      rng = Random.new(seed)
      want = got = nil
      (1..t).each do |s|
        combos = (0...self::FACTORS.size).to_a.combination(s).to_a
        want = all_tuples(s)
        unless only.empty?
          want.reject! do |kk, _|
            ti, ls = unkey(kk, s)
            combos[ti].each_with_index.any? do |f, x|
              only.key?(self::NAMES[f]) && self::FACTORS[f][1][ls[x]] != only[self::NAMES[f]]
            end
          end
        end
        got = tuples_of(cases, s)
        parts = s > 1 ? tuples_of(cases, s - 1) : {}
        part_index = (0...self::FACTORS.size).to_a.combination(s - 1).each_with_index.to_h
        want.each_key do |kk|
          next if got.key?(kk)
          ti, ls = unkey(kk, s)
          fs = combos[ti]
          next if s > 1 && (0...s).any? do |x|
            parts[key(part_index[fs[0...x] + fs[(x + 1)..]], ls[0...x] + ls[(x + 1)..])].nil?
          end
          fixed = fs.each_with_index.to_h { |f, x| [self::NAMES[f], self::FACTORS[f][1][ls[x]]] }
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
            c = render(cases.last.id + 1, base.merge(fixed).merge(only))
            next unless fixed.merge(only).all? { |f, l| c.realized[f] == l }
            cases << c
            got.merge!(tuples_of([c], s))
            parts.merge!(tuples_of([c], s - 1)) if s > 1
            break
          end
        end
      end
      [cases, want.size, want.count { |kk, _| got.key?(kk) }]
    end

    # The levels a spec such as "name_clash=sibling,seed=poly" pins.
    def pins(spec)
      spec.split(",").to_h do |pair|
        f, l = pair.split("=", 2)
        levels = self::FACTORS.to_h[f.to_s.to_sym] or raise ArgumentError, "no factor #{f.inspect}"
        level = levels.find { |x| x.to_s == l } or raise ArgumentError, "#{f} has no level #{l.inspect}"
        [f.to_sym, level]
      end
    end

    # The cases of `rows` with the levels of `only` pinned, numbered from
    # `first + 1`, to ask one level's combinations without a whole run: a
    # row that does not take them once rendered, or takes the levels of a
    # case before it, is left out.
    def pinned_cases(rows, only, first = 0)
      return cases(rows, first) if only.empty?
      seen = {}
      got = rows.each_with_object([]) do |row, out|
        c = render(first + out.size + 1, row.merge(only))
        next if seen[c.realized] || only.any? { |f, l| c.realized[f] != l }
        seen[c.realized] = true
        out << c
      end
      raise ArgumentError, "no case takes #{only.map { |f, l| "#{f}=#{l}" }.join(",")}" if got.empty?
      got
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
      self::FACTORS.to_h { |f, l| [f, l[rng.rand(l.size)]] }
    end

    def random_rows(n, seed)
      rng = Random.new(seed)
      Array.new(n) { random_row(rng) }
    end

    # The cases of `rows`, numbered from `first + 1`.
    def cases(rows, first = 0)
      rows.each_with_index.map { |row, j| render(first + j + 1, row) }
    end

    # The factors where `c` is not at its simplest level, as the probe names
    # a finding's shape.
    def shape(c)
      self::NAMES.reject { |f| c.realized[f] == self::SIMPLEST[f] }.map { |f| "#{f}=#{c.realized[f]}" }.join(" ")
    end
  end

  module_function

  def run_timed(argv, timeout, out_path, err_path)
    # one path for both streams is opened once: two opens keep two offsets,
    # and each stream writes over the other's lines
    redirect = out_path == err_path ? { [:out, :err] => out_path } : { out: out_path, err: err_path }
    pid = Process.spawn(*argv, in: File::NULL, **redirect)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    loop do
      got, status = Process.waitpid2(pid, Process::WNOHANG)
      return [status, false] if got
      if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
        Process.kill("KILL", pid) rescue nil
        Process.waitpid2(pid)
        return [nil, true]
      end
      sleep 0.02
    end
  end

  # The lines of a run, grouped by the case id each begins with.
  def by_case(text)
    h = Hash.new { |hh, k| hh[k] = [] }
    text.each_line do |l|
      id, rest = l.chomp.split(" ", 2)
      h[id.to_i] << rest.to_s if id =~ /\A\d+\z/
    end
    h
  end

  # The top-level elements of an Array's inspect, or nil for anything else.
  def elements(s)
    return nil unless s.start_with?("[") && s.end_with?("]")
    out = [+""]
    depth = 0
    quote = false
    s[1...-1].each_char do |ch|
      quote = !quote if ch == "\""
      depth += 1 if !quote && "[{(".include?(ch)
      depth -= 1 if !quote && "]})".include?(ch)
      if ch == "," && depth.zero? && !quote
        out << +""
      else
        out[-1] << ch
      end
    end
    out.map(&:strip)
  end

  # What kind of difference answer line `g` is from `w`, stable while a case
  # shrinks: a raise CRuby has and spinel lacks, the reverse, another class
  # or message, or another value (and the first place in the answer it
  # differs, named `word`@N). Nil when the answers are the same.
  def answer_kind(w, g, word)
    err = ->(r) { r[/\A([A-Z][\w:]*): /, 1] }
    we = err.call(w)
    ge = err.call(g)
    return "no-raise(#{we})" if we && !ge
    return "spurious-raise(#{ge})" if ge && !we
    return "raise-class(#{we}->#{ge})" if we && we != ge
    return "raise-message(#{we})" if we && w != g
    return nil if w == g
    wv = elements(w)
    gv = elements(g)
    at = wv && gv ? (0...[wv.size, gv.size].max).find { |x| wv[x] != gv[x] } : nil
    at ? "#{word}@#{at}" : word
  end

  # The kind of a difference in the number of lines, or nil when both have
  # as many.
  def count_kind(want, got)
    return "no-answer" if got.nil? || got.empty?
    return "extra-answer" if got.size > want.size
    return "missing-answer" if got.size < want.size
    nil
  end

  # A refusal or C error in words that do not change as a case shrinks.
  def error_kind(detail)
    detail.sub(/\Aspinel: /, "").sub(LOCATION, "").gsub(/node \d+/, "node N").gsub(/\b[a-z_]+\d+\b/, "#")
          .sub(/ \(\w+Node.*\z/, "").sub(/ recv=.*\z/, "")[0, 100]
  end

  class Probe
    attr_reader :findings

    # `documented`: the differences docs/limitations.md gives as the answer
    # on purpose, each
    #   { doc: "limitations.md, \"<section>\": <what it says>",
    #     when: ->(r) { <the case's realized levels> }, answer: /<spinel's line>/ }
    # `undefined`: CRuby's line for a name the generator's programs read and
    # do not define, which makes the program wrong, not spinel.
    def initialize(gen, spinel, ruby, timeout, dir, documented, undefined)
      @gen = gen
      @spinel = spinel
      @ruby = ruby
      @timeout = timeout
      @dir = dir
      @documented = documented
      @undefined = undefined
      @findings = []
      @lock = Mutex.new
      @seq = 0
    end

    def scratch(tag)
      n = @lock.synchronize { @seq += 1 }
      File.join(@dir, "#{tag}_#{n}")
    end

    # CRuby's lines for `cases`, by id.
    def expected(cases)
      base = scratch("ref")
      File.write(base + ".rb", @gen.program(cases))
      status, timed_out = ProbeCommon.run_timed([@ruby, "-W0", base + ".rb"], @timeout, base + ".out", base + ".err")
      raise "CRuby did not run #{base}.rb to its end" if timed_out || !status.success?
      out = File.read(base + ".out")
      if (bad = out[@undefined])
        raise @gen::GeneratorError, "a generated program reads a name it does not define (#{bad})"
      end
      ProbeCommon.by_case(out)
    end

    # Spinel's outcome for `cases` as one program.
    def spinel(cases)
      base = scratch("sp")
      File.write(base + ".rb", @gen.program(cases))
      argv = [@spinel, *@gen.flags(cases), base + ".rb", "-o", base + ".bin"]
      status, timed_out = ProbeCommon.run_timed(argv, 600, base + ".build", base + ".build")
      build = File.read(base + ".build")
      unless !timed_out && status.success?
        # C that does not build first: its diagnostics can quote generated C
        # that says "unsupported". A refusal is the compiler's own line naming
        # the construct at a Ruby line, or its tally of them.
        refusal = /^spinel: (?:\S+\.rb:\d+: )?unsupported /
        label = if !timed_out && status.signaled? then "compiler-failure"
                elsif build.include?("C compilation failed") then "link-error"
                elsif build.match?(refusal) || build.match?(/\d+ refusals?, nothing written/) then "compile-error"
                else "compiler-failure"
                end
        first = build.lines.find { |l| l.include?("error:") || l.match?(refusal) }
        first ||= if timed_out then "spinel ran past 600s"
                  elsif status.signaled? then "spinel died of SIG#{Signal.signame(status.termsig)}"
                  else build.lines.last.to_s
                  end
        return Outcome.new(label, first.strip.sub(LOCATION, ""))
      end
      status, timed_out = ProbeCommon.run_timed([base + ".bin"], @timeout, base + ".out", base + ".err")
      return Outcome.new("timeout", "no answer after #{@timeout}s") if timed_out
      return Outcome.new("crash", "SIG#{Signal.signame(status.termsig)}") if status.signaled?
      Outcome.new("ran", "", ProbeCommon.by_case(File.read(base + ".out")), status.exitstatus,
                  File.read(base + ".err"))
    end

    def record(f)
      @lock.synchronize { @findings << f }
      f
    end

    # What kind of difference `got` is from `want` in case `c`: the
    # generator's own reading of its lines when it has one, else the
    # call-binding probe's (an answer and the order its arguments ran in).
    def diff_kind(want, got, c)
      @gen.respond_to?(:diff_kind) ? @gen.diff_kind(want, got, c) : Probe.diff_kind(want, got)
    end

    # A difference between lines that end in the order their values ran in
    # (`<answer> [1, 2]`): the answer's kind, else "order".
    def self.diff_kind(want, got)
      if (k = ProbeCommon.count_kind(want, got))
        return k
      end
      w, g = want.zip(got).find { |a, b| a != b }
      return "exit-status" if w.nil?
      split = ->(l) { l =~ /\A(.*) (\[[\d, ]*\])\z/ ? [$1, $2] : [l, ""] }
      wr, wl = split.call(w)
      gr, gl = split.call(g)
      ProbeCommon.answer_kind(wr, gr, "binding") || (wl != gl ? "order" : "other")
    end

    # One case alone: [label, kind, CRuby's lines, spinel's lines, detail].
    # The label is "ran" when the two agree.
    def judge(c)
      want = expected([c])[c.id]
      o = spinel([c])
      if o.label == "ran"
        got = o.lines[c.id]
        return ["ran", nil, want, got, ""] if got == want && o.status.zero?
        detail = o.status.zero? ? "" : "exit #{o.status}: #{o.stderr.lines.first.to_s.strip}"
        return ["output-diff", diff_kind(want, got, c), want, got, detail]
      end
      [o.label, ProbeCommon.error_kind(o.detail), want, nil, o.detail]
    end

    def documented(f)
      return nil unless f.label == "output-diff"
      line = f.got.to_a.find { |l| !f.want.to_a.include?(l) } || ""
      @documented.find { |d| d[:when].call(f.c.realized) && line.match?(d[:answer]) }
    end

    # Runs `cases` (whose CRuby lines are `want`), splitting a failure that
    # takes the whole program down until one case carries it. Answers the
    # findings it recorded.
    def check(cases, want)
      o = spinel(cases)
      stopped = o.label == "ran" && (!o.status.zero? || cases.any? { |c| o.lines[c.id].empty? && !want[c.id].empty? })
      if o.label == "ran" && !stopped
        cases.reject { |c| o.lines[c.id] == want[c.id] }.map do |c|
          l, k, w, g, det = judge(c)
          record(if l == "ran"
                   interaction(cases, "case #{c.id} differs only beside the other cases of its program",
                               want[c.id], o.lines[c.id])
                 else
                   Finding.new(c, l, det, w, g, k, nil, [])
                 end)
        end
      elsif cases.size == 1
        l, k, w, g, det = judge(cases[0])
        return [] if l == "ran" # the case alone agrees: nothing to report
        [record(Finding.new(cases[0], l, det, w, g, k, nil, []))]
      else
        h = cases.size / 2
        found = check(cases[0...h], want) + check(cases[h..], want)
        # the halves have to show the failure the whole program showed; when
        # none does, it needs cases from both
        shown = found.any? do |f|
          if stopped
            %w[no-answer missing-answer exit-status].include?(f.kind) || %w[crash timeout].include?(f.label)
          else
            f.label == o.label && ProbeCommon.error_kind(f.detail) == ProbeCommon.error_kind(o.detail)
          end
        end
        return found if shown
        detail = stopped ? "the program stopped part way" : "#{o.label}: #{o.detail}"
        found + [record(interaction(cases, detail, nil, nil))]
      end
    end

    # A failure the cases of `cases` make only together, filed under its own
    # name: several can start at the same case.
    def interaction(cases, detail, want, got)
      name = "interaction_#{@lock.synchronize { @seq += 1 }}_cases_#{cases.first.id}-#{cases.last.id}"
      Finding.new(cases[0], "interaction", detail, want, got, "interaction", @gen.program(cases), [], nil, name)
    end

    # The cases one step simpler than `c`: a factor at its simplest level, or
    # a count one less. A step the case cannot take renders `c` again and is
    # no step.
    def simpler(c)
      @gen::NAMES.flat_map do |f|
        next [] if c.realized[f] == @gen::SIMPLEST[f]
        steps = [@gen::SIMPLEST[f]]
        steps.unshift(c.realized[f] - 1) if c.realized[f].is_a?(Integer) && c.realized[f] > 1
        steps.uniq.map { |l| @gen.render(c.id, c.realized.merge(f => l)) }.reject { |s| s.realized == c.realized }
      end
    end

    # Shrinks one finding while its case alone makes the same difference.
    def shrink(f, budget)
      c = f.c
      evals = 0
      loop do
        step = simpler(c).find do |s|
          break nil if (evals += 1) > budget
          l, k, = judge(s)
          l == f.label && k == f.kind
        end
        break unless step
        c = step
      end
      _l, _k, w, g, det = judge(c)
      Finding.new(c, f.label, det.to_s.empty? ? f.detail : det, w, g, f.kind, nil, [], evals > budget)
    end

    # Reduces the findings, simplest first, `jobs` at a time. A finding that
    # makes the same difference as one reduced in an earlier wave, and takes
    # every level that one still needs, is absorbed into it instead.
    def reduce(jobs, budget = 80)
      nondefault = ->(c) { @gen::NAMES.count { |x| c.realized[x] != @gen::SIMPLEST[x] } }
      todo = @findings.reject { |f| f.label == "interaction" || documented(f) }
      todo.each { |f| f.kind ||= f.label == "output-diff" ? diff_kind(f.want, f.got, f.c) : ProbeCommon.error_kind(f.detail) }
      todo.sort_by! { |f| [nondefault.call(f.c), f.c.id] }
      reduced = []
      todo.each_slice(jobs) do |wave|
        wave.map do |f|
          into = reduced.find do |r|
            r.label == f.label && r.kind == f.kind &&
              @gen::NAMES.all? { |x| r.c.realized[x] == @gen::SIMPLEST[x] || r.c.realized[x] == f.c.realized[x] }
          end
          into ? [f, into, nil] : [f, nil, Thread.new { shrink(f, budget) }]
        end.each do |f, into, thread|
          if into
            into.absorbed << f
            @findings.delete(f)
          else
            r = thread.value
            @findings[@findings.index(f)] = r
            reduced << r
          end
        end
      end
    end

    def tier(f)
      return "documented" if documented(f)
      WRONG.include?(f.label) ? "wrong" : "refused"
    end

    # A finding's shape: the factors its case needs, or for an interaction
    # the program that needs several cases.
    def shape(f)
      f.label == "interaction" ? "a program of several cases" : @gen.shape(f.c)
    end

    def family(f)
      f.kind && f.kind != f.label ? "#{f.label} #{f.kind}" : f.label
    end

    def note(f)
      n = ["# #{f.label}: case #{f.c.id}: #{shape(f)}"]
      n << "# #{f.kind}" if f.kind && f.kind != f.label
      n << "# #{f.detail}" unless f.detail.to_s.empty? || f.detail == f.kind
      n << "# reduction stopped at its step budget" if f.stopped
      if (d = documented(f))
        n << "# documented: #{d[:doc]}"
      end
      n << "# CRuby:"
      f.want.to_a.each { |l| n << "#   #{l}" }
      if f.got
        n << "# spinel:"
        f.got.each { |l| n << "#   #{l}" }
      end
      n.join("\n") + "\n"
    end

    def write_findings(out)
      @findings.each do |f|
        d = File.join(out, f.label)
        FileUtils.mkdir_p(d)
        File.write(File.join(d, "#{f.file}.rb"), note(f) + (f.program || @gen.program([f.c])))
        next if f.absorbed.empty?
        FileUtils.mkdir_p(File.join(d, "absorbed"))
        f.absorbed.each do |a|
          File.write(File.join(d, "absorbed", "#{a.file}.rb"),
                     note(a) + "# absorbed into ../#{f.file}.rb\n" + @gen.program([a.c]))
        end
      end
    end

    def weight(fs)
      fs.sum { |f| 1 + f.absorbed.size }
    end

    # Findings by tier and label, and how often each factor level is in a
    # case with a wrong answer, against how often it is in a case at all.
    def summary(cases, bad_ids)
      s = []
      by = @findings.group_by { |f| tier(f) }
      s << "#{cases.size} cases: #{weight(by.fetch("wrong", []))} wrong, #{weight(by.fetch("refused", []))} refused, " \
           "#{weight(by.fetch("documented", []))} documented"
      @findings.group_by { |f| "#{f.label} (#{tier(f)})" }.sort_by { |_, fs| -weight(fs) }.each do |l, fs|
        s << "  #{l}: #{weight(fs)}"
      end
      s << ""
      s << "wrong answers by factor level (cases with one / cases with the level):"
      @gen::FACTORS.each do |f, levels|
        cells = levels.filter_map do |l|
          all = cases.count { |c| c.realized[f] == l }
          next if all.zero?
          format("%s %d/%d", l, cases.count { |c| c.realized[f] == l && bad_ids[c.id] }, all)
        end
        s << "  #{f}: #{cells.join(", ")}"
      end
      s.join("\n") + "\n"
    end

    # The findings by tier, then by the difference they make (a family), then
    # by the factors their reduced case still needs (a shape), most frequent
    # first, each shape with the file of its case. Shapes in one family may
    # be one bug reached several ways or several bugs that answer alike; the
    # reduced cases tell which.
    def groups(out)
      g = @findings.group_by { |f| [tier(f), family(f), shape(f)] }
      s = []
      %w[wrong refused documented].each do |t|
        mine = g.select { |kk, _| kk[0] == t }
        next if mine.empty?
        fams = mine.group_by { |kk, _| kk[1] }
        s << "#{t}: #{fams.size} families, #{mine.size} shapes, #{weight(mine.values.flatten)} cases " \
             "(#{mine.values.flatten.sum { |f| f.absorbed.size }} of them absorbed into an earlier finding)"
        fams.sort_by { |_, shapes| -weight(shapes.flat_map(&:last)) }.each do |fam, shapes|
          s << format("  %-60s %3d cases, %d shapes", fam, weight(shapes.flat_map(&:last)), shapes.size)
          shapes.sort_by { |_, fs| -weight(fs) }.each do |(_t, _f, shape), fs|
            lead = fs.min_by { |f| f.c.src.size }
            s << format("    %3d  %s%s", weight(fs), shape.empty? ? "(every factor at its simplest)" : shape,
                        lead.stopped ? "  (reduction stopped)" : "")
            s << "         #{File.join(out, lead.label, "#{lead.file}.rb")}"
          end
        end
        s << ""
      end
      s.join("\n")
    end
  end

  # A probe's command line: `name` the tool's (tools/<name>.rb), `out` its
  # default --out, `strength` its default --strength; `documented` and
  # `undefined` as Probe takes them. Answers the exit status.
  def main(gen, name, argv, out:, strength:, undefined:, documented: [])
    usage = "usage: ruby tools/#{name}.rb [--strength T | --random N] [--seed S] [--only F=L,..] " \
            "[--batch B] [--jobs J] [--out DIR] [--timeout SEC] [--keep] [--no-reduce]"
    random = nil
    seed = 1
    only = {}
    batch = 50
    jobs = 4
    timeout = 30
    keep = false
    reduce = true
    args = argv.dup
    begin
      until args.empty?
        case args.shift
        when "--strength" then strength = Integer(args.shift)
        when "--random" then random = Integer(args.shift)
        when "--seed" then seed = Integer(args.shift)
        when "--only" then only.merge!(gen.pins(args.shift.to_s))
        when "--batch" then batch = Integer(args.shift)
        when "--jobs" then jobs = Integer(args.shift)
        when "--out" then out = File.expand_path(args.shift || raise(ArgumentError))
        when "--timeout" then timeout = Integer(args.shift)
        when "--keep" then keep = true
        when "--no-reduce" then reduce = false
        else raise ArgumentError
        end
      end
      raise ArgumentError unless (1..gen::FACTORS.size).cover?(strength) &&
                                 [batch, jobs, timeout].all?(&:positive?) && (random.nil? || random.positive?)
    rescue ArgumentError, TypeError => e
      warn "#{name}: #{e.message}" unless e.message == "ArgumentError"
      warn usage
      return 4
    end
    root = File.expand_path("..", __dir__)
    spinel = File.expand_path(ENV["SPINEL"] || File.join(root, "spinel"))
    unless File.executable?(spinel)
      warn "#{name}: no spinel at #{spinel} (build it, or set SPINEL)"
      return 4
    end
    if RUBY_VERSION < "4.0"
      warn "#{name}: ruby #{RUBY_VERSION} words its messages its own way; spinel follows 4.0"
    end
    # A directory the tool wrote holds its summary, or at least its lock (a
    # run stopped before the summary was begun); any other files are someone
    # else's.
    if File.directory?(out) && !Dir.empty?(out) && %w[summary.txt .lock].none? { |f| File.exist?(File.join(out, f)) }
      warn "#{name}: #{out} holds files the tool did not write; give --out an empty or new directory"
      return 4
    end
    FileUtils.mkdir_p(out)
    # one run at a time in a directory: another run's cleanup would take this
    # one's findings; held open to the end of the run: closing it, or letting
    # it be collected, releases the lock
    dir_lock = File.open(File.join(out, ".lock"), File::RDWR | File::CREAT)
    unless dir_lock.flock(File::LOCK_EX | File::LOCK_NB)
      warn "#{name}: another run is using #{out}; give --out another directory"
      return 4
    end

    work = nil
    probe = nil
    coverage = nil
    Thread.report_on_exception = false # a worker's failure is reported once, below
    begin
      if random
        cases = gen.pinned_cases(gen.random_rows(random, seed), only)
        coverage = "#{random} random rows (seed #{seed})"
      else
        cases, want, got = gen.covering_cases(strength, seed, 100, only)
        coverage = "#{strength}-way covering array (seed #{seed}): the cases take #{got} of the #{want} " \
                   "#{strength}-way combinations of levels; #{want - got} were not taken"
      end
      coverage += "; pinned: #{only.map { |f, l| "#{f}=#{l}" }.join(" ")}" unless only.empty?
      (LABELS + %w[work summary.txt]).each { |p| FileUtils.rm_rf(File.join(out, p)) }
      File.write(File.join(out, "summary.txt"), "run in progress\n")
      work = keep ? File.join(out, "work") : Dir.mktmpdir(name.tr("_", "-"))
      FileUtils.mkdir_p(work)
      probe = Probe.new(gen, spinel, RbConfig.ruby, timeout, work, documented, undefined)
      queue = Queue.new
      # one mode to a program
      cases.group_by { |c| gen.flags([c]) }.each_value { |cs| cs.each_slice(batch) { |b| queue << b } }
      done = 0
      progress = Mutex.new
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Array.new(jobs) do
        Thread.new do
          while (b = (queue.pop(true) rescue nil))
            probe.check(b, probe.expected(b))
            progress.synchronize { done += b.size }
            $stderr.print "\r#{done}/#{cases.size} cases, #{probe.findings.size} findings"
          end
        end
      end.each(&:join)
      $stderr.puts
      ran = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
      probe.findings.sort_by! { |f| f.c.id }
      wrong = probe.findings.select { |f| probe.tier(f) == "wrong" }
      bad_ids = wrong.reject { |f| f.label == "interaction" }.to_h { |f| [f.c.id, true] }
      version = IO.popen([spinel, "--version"], err: File::NULL, &:read).strip
      report = "spinel: #{version}\nruby: #{RUBY_DESCRIPTION}\n#{coverage}\n" +
               probe.summary(cases, bad_ids)
      if reduce && !probe.findings.empty?
        $stderr.puts "reducing #{probe.findings.size} findings"
        probe.reduce(jobs)
      end
      took = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
      report += format("\nwall time: %ds to run the cases (jobs %d)", ran, jobs) +
                (reduce ? format(", %ds with the reduction\n", took) : "\n")
      report += "\n" + probe.groups(out)
      probe.write_findings(out)
      File.write(File.join(out, "summary.txt"), report)
      puts report
      puts "findings under #{out}"
      wrong.empty? ? 0 : 1
    rescue StandardError => e
      # the tool's own failure (CRuby did not run a generated program, a
      # generator bug) is no finding; what was found before it is still
      # written
      warn "#{name}: #{e.message}"
      if probe && !probe.findings.empty?
        probe.write_findings(out)
        File.write(File.join(out, "summary.txt"),
                   "run stopped: #{e.message}\nruby: #{RUBY_DESCRIPTION}\n#{coverage}\n\n#{probe.groups(out)}")
        warn "#{name}: the findings made before it are under #{out}"
      end
      4
    ensure
      FileUtils.rm_rf(work) if work && !keep
      dir_lock.close
    end
  end
end
