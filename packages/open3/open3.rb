# Spinel bundled `open3` -- Open3.capture3 / capture2 / capture2e.
#
# The child's stdin (stdin_data:), stdout and stderr are files in a private
# temporary directory (Dir.mktmpdir, mode 0700) the spawn redirects to; once
# the child exits they are read back and removed.
# That is the whole difference from CRuby's pipes: output arrives all at once,
# after the process ends, which is what the capture forms return anyway.
# popen2/popen3/pipeline (a stream held open while the child runs) are not here.
require "tmpdir"

module Open3
  def self.__capture(cmd, stdin_data, merge, keep_err, chdir)
    env = nil
    args = cmd.dup
    env = args.shift if args[0].is_a?(Hash)
    # one string with anything a shell would interpret runs through the shell,
    # as Kernel#spawn does
    if args.size == 1 && args[0].is_a?(String) && args[0].match?(/[\s*?{}\[\]<>()~&|\\$;'`"\n#=%]/)
      args = ["/bin/sh", "-c", args[0]]
    end
    dir = Dir.mktmpdir("spinel_open3")
    outf = File.join(dir, "out")
    errf = File.join(dir, "err")
    inf = stdin_data ? File.join(dir, "in") : nil
    out = ""
    err = ""
    status = nil
    begin
      File.write(inf, stdin_data.to_s) if inf
      # no stdin_data: an empty stdin, as CRuby's closed pipe -- the child
      # reads EOF instead of the parent's input. Merged streams: stderr is
      # the child's own stdout, one file seeing both in the order written.
      opts = { out: outf, in: inf || File::NULL }
      opts[:chdir] = chdir if chdir
      if merge
        opts[:err] = [:child, :out]
      elsif keep_err
        opts[:err] = errf
      end
      pid = env ? Process.spawn(env, *args, **opts) : Process.spawn(*args, **opts)
      _, status = Process.waitpid2(pid)
      out = File.read(outf) if File.exist?(outf)
      err = File.read(errf) if !merge && keep_err && File.exist?(errf)
    ensure
      [outf, errf, inf].each { |f| File.delete(f) if f && File.exist?(f) }
      Dir.rmdir(dir)
    end
    [out, err, status]
  end

  # capture3(*cmd, stdin_data: nil, chdir: nil) -> [stdout, stderr, status]
  def self.capture3(*cmd, stdin_data: nil, binmode: false, chdir: nil)
    __capture(cmd, stdin_data, false, true, chdir)
  end

  # capture2(*cmd, stdin_data: nil, chdir: nil) -> [stdout, status]; stderr is the parent's
  def self.capture2(*cmd, stdin_data: nil, binmode: false, chdir: nil)
    out, _err, status = __capture(cmd, stdin_data, false, false, chdir)
    [out, status]
  end

  # capture2e(*cmd, stdin_data: nil, chdir: nil) -> [stdout and stderr merged, status]
  def self.capture2e(*cmd, stdin_data: nil, binmode: false, chdir: nil)
    out, _err, status = __capture(cmd, stdin_data, true, true, chdir)
    [out, status]
  end
end
