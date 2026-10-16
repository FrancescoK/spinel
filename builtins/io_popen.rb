# IO.popen with a block, reading the command's output: spliced by the parser
# for a program that calls IO.popen, and reached through the analysis'
# rename (desugar_io_popen_block). CRuby runs the command with its stdout on
# a pipe, yields the read end, closes it and waits for the child, so `$?`
# is the command's status once the block returns. A write mode ("w", "r+")
# raises NotImplementedError; the blockless form, which answers the IO and
# reaps on close, keeps the compiler's refusal.
class IO
  def self.__sp_popen(cmd, mode = "r", **opts)
    unless mode.start_with?("r") && !mode.include?("+")
      raise NotImplementedError, "IO.popen with mode #{mode.inspect}: only the read modes are supported"
    end
    r, w = IO.pipe
    pid = begin
      Process.spawn(*(cmd.is_a?(Array) ? cmd : [cmd]), out: w, **opts)
    rescue SystemCallError
      w.close
      r.close
      raise
    end
    w.close
    r.binmode if mode.include?("b")
    begin
      yield r
    ensure
      r.close
      Process.wait(pid)
    end
  end
end
