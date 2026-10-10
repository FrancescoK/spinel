# make gate-tool-test: tools/gate.rb in a throwaway repository. Run by the
# Ruby tools/gate-ruby picks, which is also the CRuby that judges .expected.
require "rbconfig"
require "stringio"
require "tmpdir"
require_relative "../../tools/gate"

$fails = 0

def ok(cond, what)
  puts "#{cond ? "ok  " : "FAIL"} #{what}"
  $fails += 1 unless cond
end

def sh(*cmd)
  system(*cmd, out: File::NULL, err: File::NULL) or abort "gate-tool-test: #{cmd.join(" ")} failed"
end

# Runs the block with $stdout and $stderr captured; returns [value, out, err].
def capture
  out, err = $stdout, $stderr
  $stdout, $stderr = StringIO.new, StringIO.new
  v = yield
  [v, $stdout.string, $stderr.string]
ensure
  $stdout, $stderr = out, err
end

def commit(msg) = sh("git", "commit", "-q", "-m", msg)

def stamp = File.exist?(Gate.stamp_path) && File.read(Gate.stamp_path)

def gated(&) = capture { Gate.start; yield if block_given?; Gate.stamp }

ruby = RbConfig.ruby
Dir.mktmpdir("gate-tool-test") do |dir|
  Dir.chdir(dir)
  ENV.delete("GATE_MASTER")
  ENV["GATE_RUBY"] = ruby
  sh("git", "init", "-q", "-b", "master")
  sh("git", "config", "user.email", "t@example.com")
  sh("git", "config", "user.name", "t")
  File.write("a.txt", "1\n")
  sh("git", "add", "a.txt")
  commit("base")
  sh("git", "update-ref", "refs/remotes/origin/master", "HEAD")
  sh("git", "switch", "-q", "-c", "work")
  File.write("b.txt", "work\n")
  sh("git", "add", "b.txt")
  commit("work")

  # The stamp: written for an unchanged tree, not for one edited mid-gate.
  gated
  s = stamp
  ok(s && s.include?("tree=#{Gate.merged_tree("origin/master", "HEAD")}"), "stamp records the tested tree")
  File.delete(Gate.stamp_path) if s
  _, _, err = gated { File.write("b.txt", "edited during the gate\n") }
  ok(!stamp && err.include?("no stamp"), "no stamp when the tree changed during the gate")
  sh("git", "checkout", "-q", "b.txt")

  # The trailer: only for a commit that gives the tested tree.
  gated
  File.write("msg", "work\n\nGate: green tree 000000000000 master 000000000000 (x) tests 0/0\n")
  Gate.trailer("msg")
  ok(File.read("msg").scan(/^Gate: /).size == 1 && !File.read("msg").include?("tree 000000000000"),
     "trailer replaces a stale Gate: line for the tested tree")
  sh("git", "commit", "-q", "--amend", "-F", "msg")
  ok(capture { Gate.verify("HEAD") }[0] == 0, "verify OK on the gated commit")
  File.write("b.txt", "changed after the gate\n")
  sh("git", "add", "b.txt")
  File.write("msg2", "work\n")
  Gate.trailer("msg2")
  ok(!File.read("msg2").include?("Gate: "), "no trailer for a tree that was not tested")
  sh("git", "commit", "-q", "--amend", "--no-edit")
  v, out, = capture { Gate.verify("HEAD") }
  ok(v == 1 && out.start_with?("MISMATCH"), "verify MISMATCH on a commit amended after the gate")
  sh("git", "reset", "-q", "--hard", "HEAD@{1}")

  # A rebase onto a moved master keeps the trailer's text but not its truth.
  sh("git", "switch", "-q", "master")
  File.write("a.txt", "2\n")
  sh("git", "add", "a.txt")
  commit("master moves")
  sh("git", "update-ref", "refs/remotes/origin/master", "HEAD")
  sh("git", "switch", "-q", "work")
  sh("git", "rebase", "-q", "master")
  v, out, = capture { Gate.verify("HEAD") }
  ok(v == 1 && out.start_with?("MISMATCH"), "verify MISMATCH after a rebase onto a moved master")
  v, out, = capture { Gate.verify("master") }
  ok(v == 2 && out.start_with?("NO GATE TRAILER"), "verify NO GATE TRAILER on an ungated commit")

  # check: a fixed /tmp path, and .expected judged by CRuby unless not-cruby.
  Dir.mkdir("test")
  check = lambda do |name, src, expected|
    File.write("test/#{name}.rb", src)
    File.write("test/#{name}.rb.expected", expected)
    sh("git", "add", "test/#{name}.rb", "test/#{name}.rb.expected")
    r = capture { Gate.check }
    sh("git", "rm", "-q", "--cached", "test/#{name}.rb", "test/#{name}.rb.expected")
    r
  end
  v, _, err = check.("tmp_path", "File.write(\"/tmp/x\", \"\")\n", "")
  ok(v == 1 && err.include?("fixed /tmp path"), "check refuses a fixed /tmp path")
  v, _, err = check.("same", "puts 1\n", "1\n")
  ok(v == 0 && err.empty?, "check passes an .expected CRuby agrees with")
  v, _, err = check.("differs", "puts 1\n", "2\n")
  ok(v == 1 && err.include?(".expected differs"), "check refuses an .expected CRuby disagrees with")
  v, _, err = check.("utf8_out", "puts \"\\u2192\"\n", "\u2192\n")
  ok(v == 0 && err.empty?, "check passes a non-ASCII .expected CRuby agrees with")
  v, _, err = check.("own", "# spinel: not-cruby -- spinel's own answer\nputs 1\n", "2\n")
  ok(v == 0 && err.empty?, "check skips the comparison for `# spinel: not-cruby`")
  File.write("old-ruby", "#!/bin/sh\nprintf 3.2.3\n")
  File.chmod(0o755, "old-ruby")
  ENV["GATE_RUBY"] = File.join(dir, "old-ruby")
  v, _, err = check.("differs", "puts 1\n", "2\n")
  ok(v == 0 && err.lines.size == 1 && err.include?("not checked"), "an older Ruby skips the .expected check with one warning")
  ENV["GATE_RUBY"] = ruby

  # check-range: the same checks on a range's change, as CI runs them on a
  # pull request's merge commit (HEAD^1 HEAD).
  add_commit = lambda do |files, msg|
    files.each { |f, body| File.write(f, body) }
    sh("git", "add", *files.keys)
    commit(msg)
  end
  sh("git", "switch", "-q", "-c", "range")
  base = Gate.git("rev-parse", "HEAD")
  add_commit.({ "test/r_ok.rb" => "puts 1\n", "test/r_ok.rb.expected" => "1\n" }, "a test")
  v, _, err = capture { Gate.check_range(base, "HEAD") }
  ok(v == 0 && err.empty?, "check-range passes a test whose .expected CRuby agrees with")
  add_commit.({ "test/r_old.rb" => "puts 1\n", "test/r_old.expected" => "1\n" }, "a test under the old name")
  v, _, err = capture { Gate.check_range(base, "HEAD") }
  ok(v == 1 && err.include?("no test/r_old.rb.expected; rename test/r_old.expected"),
     "check-range refuses an .expected the harness does not read, naming the rename")
  sh("git", "reset", "-q", "--hard", "HEAD^")
  add_commit.({ "test/r_bad.rb" => "puts 1\n", "test/r_bad.rb.expected" => "2\n" }, "a wrong .expected")
  v, _, err = capture { Gate.check_range(base, "HEAD") }
  ok(v == 1 && err.include?("test/r_bad.rb: .expected differs"), "check-range refuses an .expected CRuby disagrees with")
  sh("git", "reset", "-q", "--hard", "HEAD^")
  Dir.mkdir("src") unless Dir.exist?("src")
  add_commit.({ "src/grown.c" => "static int grown(void) {\n#{"  x++;\n" * Gate::FUNCTION_LIMIT}}\n" }, "a big function")
  v, _, err = capture { Gate.check_range(base, "HEAD") }
  ok(v == 1 && err.include?("new function grown"), "check-range refuses a new function past FUNCTION_LIMIT lines")
  sh("git", "reset", "-q", "--hard", "HEAD^")
  # What the base gained after the branch point is not the range's change.
  sh("git", "switch", "-q", "master")
  add_commit.({ "test/m_only.rb" => "puts 1\n" }, "master gains a test without .expected")
  # (master is checked out, so range's test is not in the working tree and
  # CRuby does not judge it: one warning)
  v, _, err = capture { Gate.check_range("master", "range") }
  ok(v == 0 && !err.include?("m_only") && err.include?("r_ok.rb differs in the working tree"),
     "check-range judges the change since the merge base, not the base's own commits")
  # CI's form: a merge commit against its first parent.
  sh("git", "merge", "-q", "--no-ff", "-m", "merge range", "range")
  v, _, err = capture { Gate.check_range("HEAD^1", "HEAD") }
  ok(v == 0 && err.empty?, "check-range HEAD^1 HEAD passes a merge whose side is clean")
  sh("git", "reset", "-q", "--hard", "HEAD^")
  sh("git", "switch", "-q", "range")
  add_commit.({ "test/r_bad.rb" => "puts 1\n", "test/r_bad.rb.expected" => "2\n" }, "a wrong .expected")
  sh("git", "switch", "-q", "master")
  sh("git", "merge", "-q", "--no-ff", "-m", "merge range", "range")
  v, _, err = capture { Gate.check_range("HEAD^1", "HEAD") }
  ok(v == 1 && err.include?("test/r_bad.rb: .expected differs"), "check-range HEAD^1 HEAD refuses what the merged side brings")
  v, _, err = capture { Gate.check_range("no-such-ref", "HEAD") }
  ok(v == 2 && err.include?("no merge base"), "check-range names a range it cannot resolve")
  sh("git", "reset", "-q", "--hard", "HEAD~2")
  sh("git", "switch", "-q", "work")
  Dir.rmdir("src") if Dir.exist?("src") && Dir.empty?("src")

  # The platform names the compiler behind a launcher given by its path.
  if Gate.run("cc", "-dumpversion")
    ENV["CC"] = "/no/such/dir/ccache cc"
    ok(Gate.compiler.match?(/\A(gcc|clang)-\d/), "the compiler's version behind a ccache path")
    ENV.delete("CC")
  end

  # The function-size rule.
  Dir.mkdir("src")
  File.write("src/big.c", "static int big(void) {\n#{"  x++;\n" * Gate::FUNCTION_LIMIT}}\n")
  sh("git", "add", "src/big.c")
  v, _, err = capture { Gate.check }
  ok(v == 1 && err.include?("new function big"), "check refuses a new function past FUNCTION_LIMIT lines")
  sh("git", "rm", "-q", "--cached", "src/big.c")

  # A UTF-8 source under a C locale, where git's output reads as US-ASCII.
  File.write("src/utf8.c", "/* a \u2192 b */\nstatic int f(void) {\n  return 0;\n}\n")
  sh("git", "add", "src/utf8.c")
  ext = Encoding.default_external
  begin
    $VERBOSE, verbose = nil, $VERBOSE
    Encoding.default_external = Encoding::US_ASCII
    v, _, err = capture { Gate.check }
  rescue ArgumentError => e
    v, err = :raised, e.message
  ensure
    Encoding.default_external = ext
    $VERBOSE = verbose
  end
  ok(v == 0 && err.empty?, "check reads a UTF-8 source under a US-ASCII locale")
  sh("git", "rm", "-q", "--cached", "src/utf8.c")

  # Under a C locale the CRuby that judges a test still answers as under
  # UTF-8 (there `p` would print an accent as an escape), and a test's .args
  # and a file name git prints unquoted hold bytes over 127.
  sh("git", "config", "core.quotePath", "false")
  File.write("test/caf\u00e9.rb.args", "caf\u00e9\n")
  src = "puts ARGV[0]\np \"caf\u00e9\"\n"
  locale = ENV["LC_ALL"]
  Encoding.default_external = Encoding::US_ASCII
  ENV["LC_ALL"] = "C"
  v, _, err = check.("caf\u00e9", src, "caf\u00e9\n\"caf\u00e9\"\n")
  ok(v == 0 && err.empty?, "check passes a test with a non-ASCII name, argument and output under a C locale")
  v, _, err = check.("caf\u00e9", src, "cafe\n\"cafe\"\n")
  ok(v == 1 && err.include?(".expected differs"), "check refuses its wrong .expected under a C locale")
  Encoding.default_external = ext
  ENV["LC_ALL"] = locale
end

# The sharing leg accepts only listed corpus failures, including package
# names, and keeps improvements non-fatal so the list can shrink.
Dir.mktmpdir("gate-shared-test") do |dir|
  script = File.expand_path("../../tools/shared_test_results.awk", __dir__)
  list = File.join(dir, "known-failures.txt")
  result = File.join(dir, "pkg.stringio.sample.ok")
  judge = lambda do |known, status|
    File.write(list, known)
    File.write(result, "#{status}\n")
    Open3.capture2e("awk", "-f", script, list, result)
  end
  out, st = judge.("# failures\n\npkg.stringio.sample # reason\n", "FAIL")
  ok(st.success? && out.include?("1 known failures"), "sharing accepts a listed package failure and comments")
  out, st = judge.("pkg.stringio.sample\n", "ERR")
  ok(st.success? && out.include?("known ERR: pkg.stringio.sample"), "sharing accepts a listed compile error")
  out, st = judge.("", "FAIL")
  ok(!st.success? && out.include?("FAIL: pkg.stringio.sample (not in known-failures.txt)"),
     "sharing rejects an unlisted failure with an empty list")
  out, st = judge.("# empty\n", "ERR")
  ok(!st.success? && out.include?("ERR: pkg.stringio.sample"), "sharing rejects an unlisted compile error")
  out, st = judge.("pkg.stringio.sample\n", "PASS")
  ok(st.success? && out.include?("passes; remove it from the list"), "sharing reports a passing listed program without failing")
  out, st = judge.("", "PASS")
  ok(st.success? && out.include?("1 pass, 0 known failures, 0 new failures"), "sharing accepts an unlisted pass")
  _, st = judge.("", "BROKEN")
  ok(!st.success?, "sharing rejects an invalid verdict")
  _, st = judge.("two names\n", "PASS")
  ok(!st.success?, "sharing rejects a malformed list")
end

if $fails > 0
  puts "gate-tool-test: #{$fails} FAILED"
  exit 1
end
puts "gate-tool-test: OK"
