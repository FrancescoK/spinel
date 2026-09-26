# A yielding method with an early `return`, inlined at a call site that
# sits inside ANOTHER method's begin..ensure body (a block handed to a
# method that yields under ensure, the way Dir.mktmpdir does). The return
# used to be routed through the caller's ensure frame -- the frame route
# fired on any open ensure -- so it returned from the CALLER: Logger#add's
# below-level early-out spliced under Dir.mktmpdir's ensure ended the whole
# program silently. The return leaves only the inlined body.
def guard(sev, msg = nil)
  return :skipped if sev < 1
  msg = yield if msg.nil? && block_given?
  msg
end

def with_cleanup
  log = []
  begin
    yield log
  ensure
    log << :cleaned
  end
  log
end

r = with_cleanup do |log|
  log << guard(0) { "dropped" }
  log << guard(2) { "kept" }
  log << guard(0, "also dropped")
  log << guard(2, "given")
end
p r

# the same under two ensure levels, and with the early-out taken last
r2 = with_cleanup do |outer|
  begin
    outer << guard(2) { "inner kept" }
    outer << guard(0) { "inner dropped" }
  ensure
    outer << :inner_cleaned
  end
end
p r2
p :after
