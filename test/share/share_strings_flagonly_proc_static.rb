# Flag-only: a static String slot's Proc argument carries its handle in
# the boxed channel, including when a later argument rebinds the slot.
class ProcStatic
  TEXT = +"constant"

  def run
    @@text = +"class"
    t = proc { |v| v }.call(@@text)
    @@text.setbyte(0, 67)
    p [@@text, t]

    $proc_text = +"global"
    g = ->(v) { v }.call($proc_text)
    $proc_text << "!"
    p [$proc_text, g]

    c = proc { |v| v }[TEXT]
    TEXT.setbyte(0, 67)
    p [TEXT, c]

    @@text = +"first"
    old = @@text
    r = proc { |v, ignored| v }.call(@@text, @@text = +"second")
    old << "!"
    p [old, r, @@text]
  end
end
ProcStatic.new.run
