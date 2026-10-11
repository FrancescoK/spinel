def pp_diff(str, single, double)
  process =
    if single ^ double then
      if single then
        lambda { |s| s == "\\n" ? "\n" : s }
      else
        lambda { |s| s == "\\\\n" ? "\\n\n" : s }
      end
    else
      :itself
    end
  str.gsub(/\\?\\n/, &process).gsub(/:0x[a-fA-F0-9]{4,}/m, ":0xXXXXXX")
end
p pp_diff("a\\nb", true, false)
p pp_diff("a\\\\nb", false, true)
p pp_diff("x:0x1234abcd", false, false)
app = proc { |s| s << "!" }
buf = +"b"
app.call(buf)
p buf
