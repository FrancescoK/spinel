#!/usr/bin/env ruby

# Generate shared builtin arity facts in src/builtin_arity.inc from local
# CRuby. Method#arity is read directly; positional counts are probed.
# codegen_call.c projects the two independent facts into its three tables.
#
#   ruby tools/gen_builtin_arity_spec.rb            # print the shared rows
#   ruby tools/gen_builtin_arity_spec.rb --write    # regenerate the rows
#   ruby tools/gen_builtin_arity_spec.rb --check    # fail when the source
#                                                   # differs (make arity-spec-check)
#
# The builtin-op rows' argc_min/argc_max (builtin_ops.c) are checked against
# the instance spec table, and the Method#arity table against it too, by
# `spinel --check-bop-arity` (make bop-arity-check-test, in the gate).
#
# Probing technique, per (class, method):
#
#   1. Counts 0..3 are called with nil arguments to locate the true MINIMUM.
#      An outcome other than a "wrong number of arguments" ArgumentError -- a
#      TypeError, a RangeError, success -- proves the COUNT is accepted (the
#      values were the problem). This must run on NON-EMPTY receivers: several
#      C methods take an empty-receiver fast path that returns before the
#      arity check ("".delete never raises), which would hide the method.
#   2. A 99-argument call makes CRuby name the accepted range in its own
#      message ("given 99, expected 0..1"), yielding the MAXIMUM and CRuby's
#      exact wording. The low-side message is captured separately from a
#      (min-1)-argument call, because branch-implemented methods word the two
#      sides differently (Range#first: 0 args is a bare read, 1.. args is
#      "expected 1").
#   3. Every count 0..12 is then VERIFIED against the derived min/max. A
#      method whose accepted set is not one contiguous range (Time.utc takes
#      1..8 OR exactly 10) is left out -- unguarded -- rather than guessed.
#
# The instance surface probed is every public method of each receiver below;
# the class-method surface is the curated list. Anything the probe cannot
# prove is omitted, so the guard the tables drive fires only where CRuby
# itself would raise.
#
# Every method is probed twice: bare, and carrying an inert block ("2.step { }"
# accepts 0 args where the bare call wants a limit; Array#fill drops to 0..2).
# Each row holds both quartets; an unprovable side is the -1 sentinel quartet.

require "timeout"
require "fileutils"
require "set"
require "socket"
require "csv"
require "json"
require "base64"
require "digest"
require "stringio"
require "strscan"
require "pathname"

Warning[:deprecated] = false  # probing deprecated arg shapes is the point
$VERBOSE = nil                # and unused blocks, superseded defaults (warn is
                              # silent from here: report with $stderr.puts)

ROOT = File.expand_path("..", __dir__)
SOURCE = File.join(ROOT, "src/builtin_arity.inc")

# Non-empty receivers (see note above), built FRESH per probe: a shared
# receiver is mutated by the probes themselves (StringIO#reopen left every
# later method probing a dead stream, losing its row).
INSTANCE_RECEIVERS = {
  "String" => -> { "ab".dup }, "Integer" => -> { 1 }, "Float" => -> { 1.0 },
  "Symbol" => -> { :a }, "Array" => -> { [1, 2] }, "Hash" => -> { {1 => 2} },
  "Range" => -> { (1..2) }, "Time" => -> { Time.at(0) },
  "NilClass" => -> { nil }, "TrueClass" => -> { true },
  "Rational" => -> { 1r }, "Complex" => -> { 1i }, "Object" => -> { Object.new },
  # native (package-backed) classes: their loose C dispatch dropped excess
  # arguments (StringIO#eof?(1) answered false), so the guard covers them too
  "StringIO" => -> { StringIO.new("ab".dup) },
  "StringScanner" => -> { StringScanner.new("ab") },
  "Pathname" => -> { Pathname.new("a") }, "Set" => -> { Set.new([1, 2]) },
  "Mutex" => -> { Mutex.new },
  # the handle kinds the guard maps by TyKind (emit_builtin_arity_guard): a
  # row must hold for every value of the kind, so Queue's rows are those
  # Queue and SizedQueue agree on (one TyKind stands for both), the IO rows
  # are probed on a File (the surface an IO handle can answer), and Struct
  # and Data instances lose their own members' accessors below
  "Regexp" => -> { /a/ }, "MatchData" => -> { "ab".match(/a/) },
  "Proc" => -> { proc { } }, "Method" => -> { 1.method(:to_s) },
  "Fiber" => -> { Fiber.new { } }, "Thread" => -> { Thread.new { }.join },
  "Queue" => -> { Queue.new([1, 2]) },
  "SizedQueue" => -> { q = SizedQueue.new(4); q << 1; q },
  "ConditionVariable" => -> { ConditionVariable.new },
  # a handle per probe would run the process out of descriptors: close the last
  "File" => -> { ($probe_io&.close rescue nil)
                 $probe_io = File.open("f", "w+"); $probe_io.write("ab"); $probe_io.rewind; $probe_io },
  "Dir" => -> { ($probe_dir&.close rescue nil); $probe_dir = Dir.new(".") },
  "Exception" => -> { RuntimeError.new("x") },
  "Enumerator" => -> { [1, 2].each }, "Random" => -> { Random.new(1) },
  "Struct" => -> { Struct.new(:a).new(1) },
  "Data" => -> { Data.define(:a).new(a: 1) },
  "Class" => -> { Class.new }, "Module" => -> { Module.new },
}

# Names whose accepted counts belong to what the receiver forwards to, not
# to its class: Method#call is its target's, Enumerator#each and to_a hand
# their arguments to the call underneath, Class#new is initialize's. Each
# keeps a row that never fires (the sentinel quartets), so the guard sees the
# class owns the name and does not read Object's row for it -- Proc#=== is
# an Object name too. A probe Struct's or Data's member accessors are the
# receiver's, not the class's, and get no row at all.
FORWARDING = {
  "Proc" => %w[call [] === yield], "Method" => %w[call [] ===],
  "Enumerator" => %w[each to_a entries to_h each_entry reverse_each],
  "Class" => %w[new],
}
PROBE_ARTEFACTS = { "Struct" => %w[a a=], "Data" => %w[a] }

# The surface probed per class: every public instance method (the arity dump
# alone missed Float#div, Integer#step, ...), minus anything that could act
# on the probing process or its I/O.
INSTANCE_METHOD_SKIP = %w[
  exit exit! fork system exec spawn sleep gets readline trap syscall
  display print puts pp p warn require require_relative load autoload
  instance_eval instance_exec class_eval module_eval eval
  taint untaint
  pread pwrite sysread syswrite readpartial read_nonblock write_nonblock
  sysseek ioctl fcntl
  set_encoding_by_bom
]
# pread (with mistyped arguments) and set_encoding_by_bom (with a block)
# each segfault CRuby 4.0.6 itself when probed; both stay off the surface.
# A class's own reader of its in-memory stream is safe to probe, though the
# names are skipped everywhere else (Kernel#gets reads stdin).
PROBE_ANYWAY = { "StringIO" => %w[gets readline], "Mutex" => %w[sleep] }
# (Mutex#sleep on the unlocked probe mutex raises ThreadError before it
# waits, for every count it accepts.)

# Class/module methods: the constructors and module functions whose emitters
# index argv[] unconditionally (File.open with no arguments crashed the
# compiler), the surface of the constants a program names bare, and the
# Kernel functions a bare call reaches. Every call is made with nil
# arguments, which Process.spawn, waitpid2 and the socket constructors
# reject before acting; still, never probe anything that could act on the
# probing process itself with any argument (fork / exec / select / sleep).
# GC.disable is undone by the GC.enable probed right after it.
CLASS_TARGETS = {
  "File"    => %w[open new read write binread binwrite readlines foreach delete unlink
                  rename exist? size basename dirname extname join split expand_path
                  chmod utime umask truncate symlink link readlink realpath stat lstat
                  ftype mtime atime ctime empty? zero? identical? absolute_path
                  file? directory? readable? writable? executable? symlink? size?
                  fnmatch fnmatch? owned? world_readable? world_writable? path
                  absolute_path? birthtime chown lchmod lchown mkfifo],
  # IO.select probes slowly (a nil-args call waits for the 2 s timeout) but
  # the row it yields is real: a missing-argument call is CRuby's
  # ArgumentError, and the probe never passes an actual IO to wait on.
  "IO"      => %w[for_fd sysopen new open read write binread binwrite readlines pipe
                  select copy_stream],
  "Dir"     => %w[new open mkdir rmdir delete unlink entries children glob foreach
                  exist? empty? home pwd getwd],
  "Time"    => %w[at local mktime utc gm now],
  "Hash"    => %w[new],
  "Array"   => %w[new],
  "String"  => %w[new],
  "Integer" => %w[sqrt],
  "Math"    => %w[sqrt cbrt sin cos tan asin acos atan atan2 sinh cosh tanh asinh acosh
                  atanh log log2 log10 exp hypot ldexp frexp erf erfc gamma lgamma],
  "Process" => %w[getpriority setpriority getsid kill clock_gettime clock_getres pid ppid
                  uid gid euid egid setproctitle times spawn waitpid2 wait2 wait waitpid],
  "Regexp"  => %w[new escape quote union],
  "Random"  => %w[new rand srand],
  "ENV"     => %w[fetch key? has_key? include? member? assoc rassoc values_at],
  "Kernel"  => %w[format sprintf Integer Float String Array Hash Rational Complex
                  throw catch raise rand srand caller lambda proc binding block_given?],
  # the class-side surface of the constants a program names bare: GC, Fiber
  # and Thread are not classes the compiler declares; a class Struct.new or
  # Data.define answered is keyed StructClass / DataClass
  "GC"      => %w[start stat compact count disable enable stress latest_gc_info],
  "Fiber"   => %w[current yield],
  "Thread"  => %w[current main list pass new start abort_on_exception
                  report_on_exception pending_interrupt? handle_interrupt],
  "StructClass" => %w[members keyword_init?],
  "DataClass"   => %w[members],
  "Marshal" => %w[dump load],
  # arity-only probing is safe here: every call is made with nil arguments,
  # which these constructors and entry points reject before acting
  "Signal"  => %w[signame list trap],
  "Socket"  => %w[new getaddrinfo getnameinfo pair socketpair gethostname sockaddr_in
                  unpack_sockaddr_in pack_sockaddr_in sockaddr_un pack_sockaddr_un],
  "TCPSocket"  => %w[new open],
  "TCPServer"  => %w[new open],
  "UNIXSocket" => %w[new open],
  "UNIXServer" => %w[new open],
  "SizedQueue" => %w[new],
  "Queue"      => %w[new],
  "Base64"  => %w[encode64 decode64 strict_encode64 strict_decode64
                  urlsafe_encode64 urlsafe_decode64],
  "CSV"     => %w[new parse parse_line generate generate_line foreach read readlines open],
  "JSON"    => %w[parse generate dump load pretty_generate],
  "Digest::MD5"    => %w[hexdigest digest base64digest file],
  "Digest::SHA1"   => %w[hexdigest digest base64digest file],
  "Digest::SHA256" => %w[hexdigest digest base64digest file],
  "StringIO"      => %w[new open],
  "StringScanner" => %w[new],
  "Pathname"      => %w[new glob getwd pwd],
}

# A top-level def is a private method of every object, the probe receivers
# included, and a builtin's internals may dispatch to it -- an Enumerator's
# size asks its target for `call` -- so these helpers keep names no
# builtin sends.
def probe_counts(thunk, m, n, block: false)
  r2 = thunk.call
  Timeout.timeout(2) do
    block ? r2.__send__(m, *Array.new(n)) { |*| "a" } : r2.__send__(m, *Array.new(n))
  end
  :ok
rescue ArgumentError => e
  e.message[/wrong number of arguments \(given #{n}, expected ([^)]+)\)/, 1] || :ok
rescue Exception
  :ok  # the count was accepted; the values (or environment) were not
end

# block: probe the counts of the block-carrying call ("2.step { }" accepts 0
# args where the bare call wants 1..; Array#fill drops to 0..2). The block
# used is inert but really runs, which is why the probe surface excludes
# anything that could act on the probing process.
def spec_of(recv, m, block: false)
  sym = m.to_sym
  return nil unless recv.call.respond_to?(sym)
  low = (0..3).map { |n| probe_counts(recv, sym, n, block: block) }
  min = low.index(:ok)
  return nil if min.nil?  # needs > 3 required args: not on this surface
  hi = probe_counts(recv, sym, 99, block: block)
  max, hi_exp =
    case hi
    when :ok then [-1, nil]
    when /\A\d+\z/, /\A\d+\.\.\d+\z/ then [hi[/(\d+)\z/, 1].to_i, hi]
    when /\A\d+\+\z/ then [-1, nil]
    else return nil  # keyword-argument wording: leave the method unguarded
    end
  return nil if min == 0 && max == -1  # nothing to enforce
  lo_exp = min > 0 && low[min - 1].is_a?(String) ? low[min - 1] : nil
  # a minimum the probe proved but whose message we could not parse: skip the
  # low side rather than guess a message
  min = 0 if min > 0 && lo_exp.nil?
  return nil if min == 0 && max == -1
  # the spec must predict every count: a gapped acceptance set (Time.utc,
  # String#bytesplice) keeps only its provable LOW side (max unenforced) --
  # every count below min must still be rejected with the same wording
  (0..12).each do |n|
    predicted_ok = n >= min && (max < 0 || n <= max)
    actual = n <= 3 ? low[n] : probe_counts(recv, sym, n, block: block)
    next if (actual == :ok) == predicted_ok
    return nil unless min > 0 && lo_exp
    (0...min).each { |k| return nil if low[k] == :ok }
    return [min, -1, lo_exp, nil]
  end
  [min, max, lo_exp, hi_exp]
end

# The bare spec plus the with-block spec in one 10-column row; a side the
# probe could not prove is the -1/NULL sentinel quartet (never fires).
NO_SPEC = [-1, -1, nil, nil]
def full_spec_of(recv, m)
  bare = spec_of(recv, m)
  blk = spec_of(recv, m, block: true)
  return nil if bare.nil? && blk.nil?
  [*(bare || NO_SPEC), *(blk || NO_SPEC)]
end

ver = RUBY_DESCRIPTION.split(" (").first

# Probe inside a throwaway directory: the Pathname receiver is the relative
# path "a", and its rmtree / delete / mkdir / write probes act on the real
# filesystem -- run anywhere else they would destroy an unrelated "./a".
require "tmpdir"
PROBE_DIR = Dir.mktmpdir("arity_probe")
Dir.chdir(PROBE_DIR)

inst = []
INSTANCE_RECEIVERS.each do |cls, thunk|
  recv = thunk.call
  meths = recv.public_methods.map(&:to_s).sort -
          (INSTANCE_METHOD_SKIP - PROBE_ANYWAY.fetch(cls, [])) -
          FORWARDING.fetch(cls, []) - PROBE_ARTEFACTS.fetch(cls, [])
  # Object's universal surface is carried by the "Object" rows; the per-class
  # rows keep only what the class itself (or its non-Object ancestry) defines,
  # so the table stays deduplicated and the guard falls back explicitly.
  unless cls == "Object"
    universal = Object.new.public_methods
    meths -= universal.map(&:to_s) - recv.class.instance_methods(false).map(&:to_s)
  end
  meths.each do |m|
    s = full_spec_of(thunk, m)
    inst << [cls, m, *s] if s
  end
  FORWARDING.fetch(cls, []).each { |m| inst << [cls, m, *NO_SPEC, *NO_SPEC] }
end
# one TyKind stands for Queue and SizedQueue both: keep the rows they agree
# on, and where SizedQueue's counts take in Queue's (push's non_block flag:
# 1 against 1..2), SizedQueue's row, which fires only for a count neither
# class takes
def spec_covers(wide, narrow)
  [0, 4].all? do |o|
    wmin, wmax, nmin, nmax = wide[o], wide[o + 1], narrow[o], narrow[o + 1]
    next wmin < 0 if nmin < 0
    wmin >= 0 && wmin <= nmin && (wmax < 0 || (nmax >= 0 && nmax <= wmax))
  end
end
sized = inst.select { |r| r[0] == "SizedQueue" }.to_h { |r| [r[1], r[2..]] }
inst.reject! { |r| r[0] == "SizedQueue" }
inst.map! do |r|
  next r unless r[0] == "Queue"
  s = sized[r[1]]
  next nil unless s
  next r if s == r[2..]
  spec_covers(s, r[2..]) ? ["Queue", r[1], *s] : nil
end
inst.compact!

CLASS_CONSTANTS = {
  "StructClass" => Struct.new(:a), "DataClass" => Data.define(:a),
}
cm = []
CLASS_TARGETS.each do |cls, meths|
  const = CLASS_CONSTANTS.fetch(cls) { Object.const_get(cls) }
  thunk = -> { const }
  meths.each do |m|
    s = full_spec_of(thunk, m)
    cm << [cls, m, *s] if s
  end
end

# Block use, per method name and positional count: whether every builtin
# instance method of the name ignores a literal block at that count, so a
# call can drop one (`[0.3, :x][k].rationalize { }`, `t.round { }`). CRuby's
# reflection does not say: a C method's Method#arity and parameters leave
# the block out, and the unused-block warning covers only methods written in
# Ruby. So each method is called with a block that raises, at counts 0..3,
# with a few sample arguments, and the block's use is read off the outcome:
#
#   - the block ran (it raised, or it ran and a rescue inside the method
#     swallowed the raise), for any sample on any receiver: the count uses
#     the block. The samples miss and hit (Hash#fetch, Hash#merge,
#     String#sub), and the receivers add the states on which some methods
#     run a block the probe receiver never reaches: an invalid-byte String
#     (String#scrub), a file and a directory Pathname (Pathname#glob),
#     empty ones;
#   - the call returned on a receiver (an empty one aside, which may return
#     before it looks at the arguments), the block did not run for any
#     sample, and no Proc of the block outlived the call (a method that
#     keeps the block, as define_singleton_method and to_enum do, uses it):
#     the count ignores the block;
#   - a count the method rejects with and without a block: the call raises
#     the same ArgumentError either way, so a dropped block changes nothing;
#   - anything else (every call raised): unproved, so the count keeps its
#     block.
#
# A name is ignorable at a count only when every class that has it (a
# Kernel/Object method once, for every class) ignores the block there or
# rejects the count, and one of them ignores it; a forwarding name and a
# name the probe skips never are. The proof is
# dynamic: it covers the samples, not every argument, which is why a sample
# set that makes the block run on any receiver wins.
class BlockRanError < Exception; end
# (a fresh Module for Module#prepend, #include and #extend, which take
# nothing else, and :ascii for the case options of upcase and its kin;
# each call gets its own copy)
BLOCK_SAMPLES = [nil, 0, 1, 99, -1, "a", "z", "*", :a, :@a, :ascii, [1], {1 => 2}, {z: 1}, Module.new]
# More receivers per class, each with whether a call returning on it is
# evidence (:full) or only a block running is (:runs, an empty receiver)
BLOCK_VARIANTS = {
  "String" => [[-> { "a\xFF".dup.force_encoding(Encoding::UTF_8) }, :full], [-> { "".dup }, :runs]],
  "Array" => [[-> { [] }, :runs]], "Hash" => [[-> { {} }, :runs]],
  "Complex" => [[-> { Complex(1, 0) }, :full]],   # 1i converts to no real
  # a file and a directory made afresh for each call: an earlier probe may
  # have renamed, removed or replaced the probe receiver's "a"
  "Pathname" => [[-> { FileUtils.rm_rf("e"); File.write("e", "ab"); Pathname.new("e") }, :full],
                 [-> { FileUtils.rm_rf("d"); FileUtils.mkdir_p("d"); FileUtils.touch("d/x"); Pathname.new("d") }, :full]],
}
# Lazy's methods keep their blocks (Lazy#map); it has no arity rows of its own
BLOCK_RECEIVERS = INSTANCE_RECEIVERS.merge("Lazy" => -> { (1..2).lazy })
UNIVERSAL_OWNERS = [Kernel, Object, BasicObject]

def block_outcome(thunk, m, args)
  ran = false
  File.chmod(0o644, "f") rescue nil  # a probed File#chmod(0) locks the probe file
  r = thunk.call
  Timeout.timeout(2) do
    r.__send__(m, *args) { |*| ran = true; raise BlockRanError }  # PROBE_BLOCK_AT
  end
  ran ? :runs : :returned
rescue BlockRanError
  :runs
rescue Timeout::Error
  ran ? :runs : :timeout
rescue ArgumentError => e
  ran ? :runs : e.message.start_with?("wrong number of arguments") ? :count : :raised
rescue Exception
  ran ? :runs : :raised
end
PROBE_BLOCK_AT = [__FILE__, __LINE__ - 12]  # the probe block, twelve lines up

def block_kept?(thunk, m, args)
  mine = -> { ObjectSpace.each_object(Proc).count { |pr| pr.source_location == PROBE_BLOCK_AT } }
  GC.disable
  before = mine.call
  block_outcome(thunk, m, args)
  mine.call > before
ensure
  GC.enable
end
# the capture test finds the probe block's Procs
unless block_kept?(-> { Object.new }, :define_singleton_method, [:a]) &&
       !block_kept?(-> { 1 }, :abs, [])
  abort "block-use probe: PROBE_BLOCK_AT does not name the probe block"
end

# The argument lists of count n: each sample n times, and for two or more
# an index or a count ahead of samples of another kind, as a variadic
# method's leading position takes one (insert(1, "a"), fill(0, 1)).
BLOCK_MIXED = [[0, "a"], [1, "a"], ["a", 0], [0, [1]], [0, :a], [1, 1.5], [:turkic, :lithuanian]]
def block_vectors(n)
  vs = BLOCK_SAMPLES.map { |v| Array.new(n, v) }
  vs += BLOCK_MIXED.map { |a, b| [a, *Array.new(n - 1, b)] } if n >= 2
  vs
end

# The counts (a bit each, 0..3) at which m ignores a block on these
# receivers, those it takes neither with nor without one, and those at which
# every call raised without running the block (`upcase(a, b, c)`: too many
# options). Each call gets fresh samples: a method may write into one
# (IO#read's buffer).
def block_ignored_mask(receivers, m)
  mask = neither = rejects = 0
  (0..3).each do |n|
    runs = false
    kept_at = nil
    counts = 0
    raised = true
    vectors = block_vectors(n)
    receivers.each do |thunk, ev|
      vectors.each do |vec|
        o = block_outcome(thunk, m, vec.map(&:dup))
        runs = true if o == :runs
        kept_at ||= [thunk, vec.map(&:dup)] if o == :returned && ev == :full
        counts += 1 if o == :count
        raised = false unless o == :count || o == :raised
        break if runs || o == :timeout
      end
      break if runs
    end
    next if runs
    rejects |= 1 << n if raised
    # a count the method takes neither with a block nor without one raises
    # the same ArgumentError either way, so the block is no matter there
    if counts == receivers.size * vectors.size && probe_counts(receivers[0][0], m, n).is_a?(String)
      neither |= 1 << n
    elsif kept_at && !block_kept?(kept_at[0], m, kept_at[1])
      mask |= 1 << n
    end
  end
  [mask, neither, rejects]
end

block_masks = {}   # [owner, m] => mask
name_keys = Hash.new { |h, k| h[k] = [] }
BLOCK_RECEIVERS.each do |cls, thunk|
  recv = thunk.call
  skipped = INSTANCE_METHOD_SKIP - PROBE_ANYWAY.fetch(cls, [])
  (recv.public_methods.map(&:to_s) - PROBE_ARTEFACTS.fetch(cls, [])).each do |m|
    owner = (recv.method(m).owner rescue nil)
    key = UNIVERSAL_OWNERS.include?(owner) ? ["Object", m] : [cls, m]
    name_keys[m] << key
    next if block_masks.key?(key)
    block_masks[key] =
      if FORWARDING.fetch(cls, []).include?(m) || skipped.include?(m) then [0, 0, 0]
      elsif key[0] == "Object" then block_ignored_mask([[INSTANCE_RECEIVERS["Object"], :full]], m)
      else block_ignored_mask([[thunk, :full], *BLOCK_VARIANTS.fetch(cls, [])], m)
      end
  end
end
# The static cross-check: RBS core's signatures (the rbs gem Ruby ships)
# declare each overload's block. A count at which any public instance
# method of the name, in any core class, has an overload that takes a
# block keeps its block, whatever the probe saw: either the probe missed a
# block that runs only for some arguments or states, or the signature
# declares a block CRuby ignores, and only the first kind matters. Read in
# a fresh interpreter, as the arity dump below is. The counts any overload
# takes, with a block or without, come along: a count no signature of the
# name takes, of a name no signature gives a block, is one CRuby rejects
# before it could use a block.
rbs_src = <<~'RUBY'
  require "rbs"
  require "json"
  loader = RBS::EnvironmentLoader.new
  env = RBS::Environment.from_loader(loader).resolve_type_names
  builder = RBS::DefinitionBuilder.new(env: env)
  out = Hash.new { |h, k| h[k] = Hash.new { |h2, k2| h2[k2] = [] } }
  takes = Hash.new { |h, k| h[k] = [] }
  env.class_decls.each_key do |tn|
    d = (builder.build_instance(tn) rescue next)
    d.methods.each do |name, m|
      next unless m.accessibility == :public
      m.method_types.each do |mt|
        f = mt.type
        unless f.respond_to?(:required_positionals)
          takes[name.to_s] |= [0, 1, 2, 3]   # an untyped parameter list takes any count
          next
        end
        lo = f.required_positionals.size + f.trailing_positionals.size
        hi = f.rest_positionals ? 3 : [lo + f.optional_positionals.size, 3].min
        takes[name.to_s] |= (lo..hi).to_a
        next unless mt.block
        (lo..hi).each { |n| out[name.to_s][n] |= [tn.to_s.delete_prefix("::")] }
      end
    end
  end
  puts JSON.generate("blocks" => out, "takes" => takes)
RUBY
require "rbconfig"
rbs = JSON.parse(IO.popen([RbConfig.ruby, "-e", rbs_src], &:read).to_s) rescue nil
abort "block-use probe: could not read RBS core's signatures (the rbs gem)" unless $?.success? && rbs&.dig("blocks")&.any?
rbs_blocks, rbs_takes = rbs.values_at("blocks", "takes")
rbs_disagree = []
rbs_rejected = []
blk = name_keys.keys.sort.filter_map do |m|
  # a count no class takes is no proof: some class the probe leaves out
  # (IO::Buffer#each_byte(type, offset)) may take it and use the block
  ms = name_keys[m].uniq.map { |k| block_masks[k] }
  mask = ms.map { |ign, neither, _| ign | neither }.reduce(:&) & ms.map(&:first).reduce(:|)
  # ...unless every call there raised without running the block, no
  # signature takes the count either, and none of the name's signatures
  # declares a block: upcase(:turkic, :lithuanian, x)
  unless rbs_blocks.key?(m) || !rbs_takes.key?(m)
    (0..3).each do |n|
      next if mask[n] == 1 || ms.map(&:last).reduce(:&)[n] == 0 || rbs_takes[m].include?(n)
      mask |= 1 << n
      rbs_rejected << "#{m}/#{n}"
    end
  end
  rbs_blocks.fetch(m, {}).each do |n, owners|
    next unless mask[n.to_i] == 1
    mask &= ~(1 << n.to_i)
    rbs_disagree << "#{m}/#{n} (#{owners.join(", ")})"
  end
  [m, mask] if mask > 0
end
# Method#arity of each class's OWN public instance methods, read straight off
# CRuby rather than probed (a C method that counts its own arguments reads
# -1 here; the spec tables above hold what it accepts), plus the Kernel
# functions the receiverless `method(:name)` wrapper binds under "Kernel".
ARITY_CLASSES = %w[String Integer Float Array Hash Symbol Range Time]
ARITY_KERNEL = %w[String Integer Float Array Rational Complex puts print p pp]

# read in a fresh interpreter with no gems: the libraries this probe loads
# add methods of their own (csv's String#parse_csv, time's Time#httpdate)
require "rbconfig"
arity_src = <<~RUBY
  #{ARITY_CLASSES.inspect}.each do |cls|
    k = Object.const_get(cls)
    k.public_instance_methods(false).sort.each { |m| puts [cls, m, k.instance_method(m).arity].join("\\t") }
  end
  #{ARITY_KERNEL.inspect}.each { |m| puts ["Kernel", m, Kernel.instance_method(m).arity].join("\\t") }
RUBY
arity_all = IO.popen([RbConfig.ruby, "--disable-gems", "-e", arity_src], &:read)
                .lines.map { |l| c, m, a = l.chomp.split("\t"); [c, m, a.to_i] }
abort "Method#arity dump failed" unless $?.success? && !arity_all.empty?
kernel_arity, arity = arity_all.partition { |r| r[0] == "Kernel" }
# Keep both facts where available; introspection is not an acceptance rule.
# Retain Method#arity order, including the receiverless Kernel wrappers.
counts = inst.to_h { |r| [r[0, 2], r[2..]] }
out = <<~C
  /* Builtin arity facts generated by tools/gen_builtin_arity_spec.rb from #{ver}.
     Method#arity and accepted positional counts are independent facts.
     BAI carries both, BAM only Method#arity, BAS only instance counts,
     and BAC class/module counts. -1 maxima are unbounded; NULL messages
     and unproved -1 minima never reject a call. Block counts are separate.
     Kernel Method#arity describes receiverless method(:name) wrappers.
     BAB gives, per method name, the positional counts (bit n for n, 0..3)
     at which every builtin instance method of the name ignores a block. */
C
render = ->(tag, values) do
  fields = values.map { |v| v.nil? ? "NULL" : v.is_a?(String) ? v.dump : v.to_s }
  out << "#{tag}(#{fields.join(",")})\n"
end
(arity + kernel_arity).each do |r|
  spec = counts.delete(r[0, 2])
  render.(spec ? "BAI" : "BAM", spec ? r + spec : r)
end
inst.each { |r| render.("BAS", r) if counts.key?(r[0, 2]) }
cm.each { |r| render.("BAC", r) }
blk.each { |r| render.("BAB", r) }
summary = "#{arity.length + kernel_arity.length} Method#arity + #{inst.length} instance + #{cm.length} class-method + #{blk.length} block-use entries"
$stderr.puts "block use: the probe saw these counts ignore a block an RBS core signature declares " \
             "(kept): #{rbs_disagree.size}", *rbs_disagree.map { |d| "  #{d}" }
$stderr.puts "block use: counts every class and every RBS core signature reject, of a name no " \
             "signature gives a block: #{rbs_rejected.size}"
if ARGV.include?("--check")
  if File.read(SOURCE) == out
    $stderr.puts "arity facts match #{ver}: #{summary}"
    exit 0
  end
  require "tempfile"
  Tempfile.create("arity") do |f|
    f.write(out)
    f.flush
    system("diff", "-u", "--label", "src/builtin_arity.inc", "--label", "regenerated", SOURCE, f.path)
  end
  abort "arity facts drifted from #{ver}: rerun tools/gen_builtin_arity_spec.rb --write"
elsif ARGV.include?("--write")
  File.write(SOURCE, out)
  $stderr.puts "wrote #{summary} into #{SOURCE}"
else
  puts out
  $stderr.puts summary
end
