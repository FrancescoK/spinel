# spinel: wasm-abort
# A program with no rescue runs as it does with exception handling: an
# ensure's body, a block's break spliced into its method, a regexp, a Hash,
# a sort, a formatted Float (#8401).
def guarded(log)
  log << :body
  :value
ensure
  log << :ensure
end
log = []
p guarded(log), log
p [3, 1, 2].sort, [5, 6, 7].each { |x| break x * 10 if x > 5 }
h = { "a" => 1, "b" => 2 }
p h.sum { |_, v| v }, "%.2f" % 2.5
p "item-42" =~ /(\d+)/ ? $1.to_i : nil
