#!/usr/bin/env ruby
# Exercise the ratchet without depending on a particular compiler bug.
require "tmpdir"
require "open3"
require "rbconfig"

root = File.expand_path("..", __dir__)
Dir.mktmpdir("share-verify-tool-") do |tmp|
  compiler = File.join(tmp, "fake compiler")
  file = File.join(tmp, "input with spaces.rb")
  ratchet = File.join(tmp, "known.txt")
  File.write(file, "puts 1\n")
  File.write("#{file}.expected", "1 😀\n")
  File.write(compiler, <<~'RUBY')
    #!/usr/bin/env ruby
    checked = ARGV.include?("--repr-check")
    mode = ENV.fetch("VERIFY_TEST_MODE")
    exit 1 if mode == "failed"
    output = ARGV[ARGV.index("-o") + 1]
    if ARGV.include?("-c")
      File.write(output, mode == "changed" && checked ? "changed" : "same")
    else
      exit 1 if mode == "build-failed"
      File.write(output, "#!/usr/bin/env ruby\nputs \"#{mode == 'wrong-output' ? 2 : 1} 😀\"\nexit #{mode == 'run-failed' ? 1 : 0}\n")
      File.chmod(0o755, output)
    end
    if checked && ["conflict", "second"].include?(mode)
      warn "repr-check: channel-conflict: node 1: missing clear"
      warn "repr-check: channel-conflict: node 2: missing clear" if mode == "second"
    end
    warn "plan-check: channel-box-conflict: node 1: bytes" if checked && mode == "plan"
  RUBY
  File.chmod(0o755, compiler)
  known = "#{file}\trepr-check: channel-conflict: node 1: missing clear\n"
  cases = [
    ["clean", "", true, nil],
    ["conflict", "", false, "NEW"],
    ["conflict", known, true, nil],
    ["clean", known, true, "STALE (remove fixed entry)"],
    ["second", known, false, "node 2"],
    ["plan", "", false, "channel-box-conflict"],
    ["changed", "", false, "generated C differs"],
    ["failed", "", false, "compile failed"],
    ["build-failed", "", false, "executable build failed"],
    ["wrong-output", "", false, "output differs"],
    ["run-failed", "", false, "program failed"],
    ["clean", known * 2, false, "duplicate ratchet entries"]
  ]
  cases.each do |mode, entries, success, message|
    File.write(ratchet, entries)
    # no gems: some 60 Ruby processes start here, and RubyGems' load was
    # most of the time, past the corpus's 10 s under the gate's load
    env = { "SPINEL" => compiler, "VERIFY_TEST_MODE" => mode, "SHARE_VERIFY_JOBS" => "2",
            "RUBYOPT" => "--disable-gems" }
    out, err, status = Open3.capture3(env, RbConfig.ruby, File.join(root, "tools/share_verify.rb"),
                                    "--ratchet", ratchet, file)
    unless status.success? == success && (!message || (out + err).include?(message))
      abort "share-verify tool: #{mode} failed: #{out}#{err}"
    end
  end
  # The default corpus also reminds about entries for files that were deleted.
  require "fileutils"
  FileUtils.mkdir_p([File.join(tmp, "tools"), File.join(tmp, "test/share/verify/conflicts")])
  runner = File.join(tmp, "tools/share_verify.rb")
  FileUtils.cp(File.join(root, "tools/share_verify.rb"), runner)
  File.write(File.join(tmp, "test/share/verify/one.rb"), "puts 1\n")
  File.write(File.join(tmp, "test/share/verify/one.rb.expected"), "1 😀\n")
  File.write(File.join(tmp, "test/share/verify/conflicts/one.rb"), "puts 2\n")
  File.write(ratchet, "test/share/deleted.rb\trepr-check: channel-conflict: node 1: missing clear\n")
  out, err, status = Open3.capture3({ "SPINEL" => compiler, "VERIFY_TEST_MODE" => "clean",
                                    "RUBYOPT" => "--disable-gems" },
                                  RbConfig.ruby, runner, "--ratchet", ratchet)
  abort "share-verify tool: deleted entry failed: #{out}#{err}" unless status.success? && err.include?("STALE (remove fixed entry)")
  puts "share-verify tool: #{cases.size + 1} checks pass"
end
