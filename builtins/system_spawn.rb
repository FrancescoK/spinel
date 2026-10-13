# Kernel#system with an options Hash (out:, err:, in:, chdir:, exception:, ...)
# or an environment Hash, spliced by the parser for a program that calls
# system: CRuby's rb_f_system is a spawn and a wait, so it is written as one
# here, over Process.spawn, which already takes those options. The analysis
# renames such a call to this method (desugar_system_options); a system call
# with neither keeps the direct path. As CRuby: true for an exit status of
# zero, false for another, nil when the command cannot run; `exception: true`
# raises the spawn's Errno instead of nil and a RuntimeError for a failed
# status.
def __sp_system_spawn(*args, **opts)
  raise_on = opts.delete(:exception)
  pid = begin
    Process.spawn(*args, **opts)
  rescue SystemCallError => e
    raise e if raise_on
    return nil
  end
  Process.wait(pid)
  st = $?
  if raise_on && !st.success?
    cmd = args.first.is_a?(Hash) ? args[1] : args.first
    raise RuntimeError, "Command failed with #{st.exitstatus ? "exit #{st.exitstatus}" : st.to_s}: #{cmd}"
  end
  st.success?
end
