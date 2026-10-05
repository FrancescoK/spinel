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
  v, _, err = check.("own", "# spinel: not-cruby -- spinel's own answer\nputs 1\n", "2\n")
  ok(v == 0 && err.empty?, "check skips the comparison for `# spinel: not-cruby`")
  File.write("old-ruby", "#!/bin/sh\nprintf 3.2.3\n")
  File.chmod(0o755, "old-ruby")
  ENV["GATE_RUBY"] = File.join(dir, "old-ruby")
  v, _, err = check.("differs", "puts 1\n", "2\n")
  ok(v == 0 && err.lines.size == 1 && err.include?("not checked"), "an older Ruby skips the .expected check with one warning")
  ENV["GATE_RUBY"] = ruby

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
end

if $fails > 0
  puts "gate-tool-test: #{$fails} FAILED"
  exit 1
end
puts "gate-tool-test: OK"
