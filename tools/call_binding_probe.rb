# Call-binding probe: generated calls, CRuby against spinel, case by case.
#
#   ruby tools/call_binding_probe.rb [--strength T | --random N] [--seed S]
#                                    [--batch B] [--jobs J] [--out DIR]
#                                    [--timeout SEC] [--keep] [--no-reduce]
#
# Takes the cases of tools/call_binding_gen.rb -- a covering array of strength
# T (default 3) over its factors, or N random rows -- runs them B to a program
# under CRuby and under spinel, and compares each case's lines. A program
# spinel refuses, whose C does not build, that crashes or that runs out of
# time is split in halves until one case carries the failure; a difference
# seen in a program is confirmed on its case alone. A failure no single case
# carries (two cases that only fail together) is kept as an `interaction`,
# with the program that showed it.
#
# Each finding is then reduced: one factor at a time steps toward its
# simplest level for as long as the case alone still makes the same kind of
# difference (for an answer that binds wrong, at the same place in it). The
# findings of a run are reduced simplest first, a few at a time; a finding
# that makes the same kind of difference as one reduced before it and takes
# every level that one still needs is taken to be that bug again and is not
# reduced itself -- it is listed under that finding's shape, its own program
# kept apart (DIR/<label>/absorbed/). That shortcut is a judgement, not a
# proof, and the summary says how many findings it absorbed. A reduction that
# runs out of steps says so.
#
# What counts as a finding follows the compiler's own contract. Ruby that
# does not parse is no case. An exception CRuby raises is part of the
# expected answer: spinel has to raise the same one, after running the same
# arguments. Spinel may refuse a program at compile time, naming the
# construct ("unsupported ...") rather than compile it wrong --
# docs/limitations.md counts that a gap -- so a refusal (label
# compile-error) is reported in the `refused` tier. A difference
# docs/limitations.md describes as the answer on purpose (DOCUMENTED below)
# is reported in the `documented` tier, citing it. Everything else that
# differs is `wrong`: another answer, exception, order of evaluation or exit
# status (output-diff), C that does not build (link-error: the compiler
# should have refused), a compiler that fails without naming a construct
# (compiler-failure), a crash, a timeout, an interaction.
#
# Output, under DIR (default build/call-binding-probe; the tool writes only
# its own files there, will not take a directory holding others, and runs
# one at a time in it):
# summary.txt (coverage, findings by tier and label, the failure rate of every
# factor level, the findings in families by the difference they make and in
# shapes by the factors they need) and <label>/case_<id>.rb, each finding's
# reduced case as a program of its own, with CRuby's answer and spinel's in a
# comment above it.
#
# Exit status: 0 no wrong answer, 1 a wrong answer, 4 the tool's own error.
# (A run is many programs, so unlike `spinel diff` one status summarizes it.)

require "fileutils"
require "rbconfig"
require "tmpdir"
require_relative "call_binding_gen"

ROOT = File.expand_path("..", __dir__)
WRONG = %w[output-diff link-error compiler-failure crash timeout interaction].freeze
LABELS = (WRONG + %w[compile-error]).freeze

# Differences docs/limitations.md gives as the answer on purpose: the path
# and parameters of the case, and what spinel answers there, each
#   { doc: "limitations.md, \"<section>\": <what it says>",
#     when: ->(r) { <the case's realized levels> }, answer: /<spinel's line>/ }
# None stands now: the bound-Method declines it listed bind as CRuby does.
DOCUMENTED = [].freeze

Outcome = Struct.new(:label, :detail, :lines, :status, :stderr)
Finding = Struct.new(:c, :label, :detail, :want, :got, :kind, :program, :absorbed, :stopped, :name) do
  # the file a finding is written to: its case's, or an interaction's own
  def file = name || "case_#{c.id}"
end
# A compiler diagnostic's location, which moves as a case shrinks.
LOCATION = /\A\S+\.(?:rb|c|h):\d+(?::\d+)?: /

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

class Probe
  attr_reader :findings

  def initialize(spinel, ruby, timeout, dir)
    @spinel = spinel
    @ruby = ruby
    @timeout = timeout
    @dir = dir
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
    File.write(base + ".rb", CallBindingGen.program(cases))
    status, timed_out = run_timed([@ruby, "-W0", base + ".rb"], @timeout, base + ".out", base + ".err")
    raise "CRuby did not run #{base}.rb to its end" if timed_out || !status.success?
    out = File.read(base + ".out")
    # a name the generator defines, undefined: the program is wrong, not spinel
    if (bad = out[/NameError: undefined local variable or method '(?:blk|[a-z])\d+(?:_\d+)?'[^\n]*/])
      raise CallBindingGen::GeneratorError, "a generated program reads a name it does not define (#{bad})"
    end
    by_case(out)
  end

  # Spinel's outcome for `cases` as one program.
  def spinel(cases)
    base = scratch("sp")
    File.write(base + ".rb", CallBindingGen.program(cases))
    status, timed_out = run_timed([@spinel, base + ".rb", "-o", base + ".bin"], 600, base + ".build", base + ".build")
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
    status, timed_out = run_timed([base + ".bin"], @timeout, base + ".out", base + ".err")
    return Outcome.new("timeout", "no answer after #{@timeout}s") if timed_out
    return Outcome.new("crash", "SIG#{Signal.signame(status.termsig)}") if status.signaled?
    Outcome.new("ran", "", by_case(File.read(base + ".out")), status.exitstatus, File.read(base + ".err"))
  end

  def record(f)
    @lock.synchronize { @findings << f }
    f
  end

  # What kind of difference `got` is from `want`, stable while a case
  # shrinks: a raise CRuby has and spinel lacks, the reverse, another class
  # or message, another value (and the first place in the answer it
  # differs), or only another order of evaluation.
  def self.diff_kind(want, got)
    return "no-answer" if got.nil? || got.empty?
    return "extra-answer" if got.size > want.size
    return "missing-answer" if got.size < want.size
    w, g = want.zip(got).find { |a, b| a != b }
    return "exit-status" if w.nil?
    split = ->(l) { l =~ /\A(.*) (\[[\d, ]*\])\z/ ? [$1, $2] : [l, ""] }
    wr, wl = split.call(w)
    gr, gl = split.call(g)
    err = ->(r) { r[/\A([A-Z][\w:]*): /, 1] }
    we = err.call(wr)
    ge = err.call(gr)
    return "no-raise(#{we})" if we && !ge
    return "spurious-raise(#{ge})" if ge && !we
    return "raise-class(#{we}->#{ge})" if we && we != ge
    return "raise-message(#{we})" if we && wr != gr
    if wr != gr
      wv = elements(wr)
      gv = elements(gr)
      at = wv && gv ? (0...[wv.size, gv.size].max).find { |x| wv[x] != gv[x] } : nil
      return at ? "binding@#{at}" : "binding"
    end
    return "order" if wl != gl
    "other"
  end

  # A refusal or C error in words that do not change as a case shrinks.
  def self.error_kind(detail)
    detail.sub(/\Aspinel: /, "").sub(LOCATION, "").gsub(/node \d+/, "node N").gsub(/\b[a-z_]+\d+\b/, "#")
          .sub(/ \(\w+Node.*\z/, "").sub(/ recv=.*\z/, "")[0, 100]
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
      return ["output-diff", Probe.diff_kind(want, got), want, got, detail]
    end
    [o.label, Probe.error_kind(o.detail), want, nil, o.detail]
  end

  def documented(f)
    return nil unless f.label == "output-diff"
    line = f.got.to_a.find { |l| !f.want.to_a.include?(l) } || ""
    DOCUMENTED.find { |d| d[:when].call(f.c.realized) && line.match?(d[:answer]) }
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
          f.label == o.label && Probe.error_kind(f.detail) == Probe.error_kind(o.detail)
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
    Finding.new(cases[0], "interaction", detail, want, got, "interaction", CallBindingGen.program(cases), [],
                nil, name)
  end

  # The cases one step simpler than `c`: a factor at its simplest level, or a
  # count one less.
  def simpler(c)
    CallBindingGen::NAMES.flat_map do |f|
      next [] if c.realized[f] == CallBindingGen::SIMPLEST[f]
      steps = [CallBindingGen::SIMPLEST[f]]
      steps.unshift(c.realized[f] - 1) if c.realized[f].is_a?(Integer) && c.realized[f] > 1
      steps.map { |l| CallBindingGen.render(c.id, c.realized.merge(f => l)) }
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
    nondefault = ->(c) { CallBindingGen::NAMES.count { |x| c.realized[x] != CallBindingGen::SIMPLEST[x] } }
    todo = @findings.reject { |f| f.label == "interaction" || documented(f) }
    todo.each { |f| f.kind ||= f.label == "output-diff" ? Probe.diff_kind(f.want, f.got) : Probe.error_kind(f.detail) }
    todo.sort_by! { |f| [nondefault.call(f.c), f.c.id] }
    reduced = []
    todo.each_slice(jobs) do |wave|
      wave.map do |f|
        into = reduced.find do |r|
          r.label == f.label && r.kind == f.kind &&
            CallBindingGen::NAMES.all? do |x|
              r.c.realized[x] == CallBindingGen::SIMPLEST[x] || r.c.realized[x] == f.c.realized[x]
            end
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

  # A finding's shape: the factors its case needs, or for an interaction the
  # program that needs several cases.
  def shape(f)
    f.label == "interaction" ? "a program of several cases" : CallBindingGen.shape(f.c)
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
      File.write(File.join(d, "#{f.file}.rb"), note(f) + (f.program || CallBindingGen.program([f.c])))
      next if f.absorbed.empty?
      FileUtils.mkdir_p(File.join(d, "absorbed"))
      f.absorbed.each do |a|
        File.write(File.join(d, "absorbed", "#{a.file}.rb"),
                   note(a) + "# absorbed into ../#{f.file}.rb\n" + CallBindingGen.program([a.c]))
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
    CallBindingGen::FACTORS.each do |f, levels|
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
  # first, each shape with the file of its case. Shapes in one family may be
  # one bug reached several ways or several bugs that answer alike; the
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

usage = "usage: ruby tools/call_binding_probe.rb [--strength T | --random N] [--seed S] [--batch B] " \
        "[--jobs J] [--out DIR] [--timeout SEC] [--keep] [--no-reduce]"
strength = 3
random = nil
seed = 1
batch = 50
jobs = 4
out = File.join(ROOT, "build/call-binding-probe")
timeout = 30
keep = false
reduce = true
args = ARGV.dup
begin
  until args.empty?
    case args.shift
    when "--strength" then strength = Integer(args.shift)
    when "--random" then random = Integer(args.shift)
    when "--seed" then seed = Integer(args.shift)
    when "--batch" then batch = Integer(args.shift)
    when "--jobs" then jobs = Integer(args.shift)
    when "--out" then out = File.expand_path(args.shift || raise(ArgumentError))
    when "--timeout" then timeout = Integer(args.shift)
    when "--keep" then keep = true
    when "--no-reduce" then reduce = false
    else raise ArgumentError
    end
  end
  raise ArgumentError unless (1..CallBindingGen::FACTORS.size).cover?(strength) &&
                             [batch, jobs, timeout].all?(&:positive?) && (random.nil? || random.positive?)
rescue ArgumentError, TypeError
  warn usage
  exit 4
end
spinel = File.expand_path(ENV["SPINEL"] || File.join(ROOT, "spinel"))
unless File.executable?(spinel)
  warn "call_binding_probe: no spinel at #{spinel} (build it, or set SPINEL)"
  exit 4
end
if RUBY_VERSION < "4.0"
  warn "call_binding_probe: ruby #{RUBY_VERSION} words its messages its own way; spinel follows 4.0"
end
# A directory the tool wrote holds its summary, or at least its lock (a run
# stopped before the summary was begun); any other files are someone else's.
if File.directory?(out) && !Dir.empty?(out) && %w[summary.txt .lock].none? { |f| File.exist?(File.join(out, f)) }
  warn "call_binding_probe: #{out} holds files the tool did not write; give --out an empty or new directory"
  exit 4
end
FileUtils.mkdir_p(out)
# one run at a time in a directory: another run's cleanup would take this one's findings
# held open to the end of the run: closing it, or letting it be collected,
# releases the lock
dir_lock = File.open(File.join(out, ".lock"), File::RDWR | File::CREAT)
unless dir_lock.flock(File::LOCK_EX | File::LOCK_NB)
  warn "call_binding_probe: another run is using #{out}; give --out another directory"
  exit 4
end

work = nil
probe = nil
coverage = nil
Thread.report_on_exception = false # a worker's failure is reported once, below
begin
  if random
    cases = CallBindingGen.cases(CallBindingGen.random_rows(random, seed))
    coverage = "#{random} random rows (seed #{seed})"
  else
    cases, want, got = CallBindingGen.covering_cases(strength, seed)
    coverage = "#{strength}-way covering array (seed #{seed}): the cases take #{got} of the #{want} " \
               "#{strength}-way combinations of levels; #{want - got} were not taken"
  end
  (LABELS + %w[work summary.txt]).each { |p| FileUtils.rm_rf(File.join(out, p)) }
  File.write(File.join(out, "summary.txt"), "run in progress\n")
  work = keep ? File.join(out, "work") : Dir.mktmpdir("call-binding-probe")
  FileUtils.mkdir_p(work)
  probe = Probe.new(spinel, RbConfig.ruby, timeout, work)
  queue = Queue.new
  cases.each_slice(batch) { |b| queue << b }
  done = 0
  progress = Mutex.new
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
  report += "\n" + probe.groups(out)
  probe.write_findings(out)
  File.write(File.join(out, "summary.txt"), report)
  puts report
  puts "findings under #{out}"
  exit(wrong.empty? ? 0 : 1)
rescue StandardError => e
  # the tool's own failure (CRuby did not run a generated program, a
  # generator bug) is no finding; what was found before it is still written
  warn "call_binding_probe: #{e.message}"
  if probe && !probe.findings.empty?
    probe.write_findings(out)
    File.write(File.join(out, "summary.txt"),
               "run stopped: #{e.message}\nruby: #{RUBY_DESCRIPTION}\n#{coverage}\n\n#{probe.groups(out)}")
    warn "call_binding_probe: the findings made before it are under #{out}"
  end
  exit 4
ensure
  FileUtils.rm_rf(work) if work && !keep
  dir_lock.close
end
