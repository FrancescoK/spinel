# spinel: wasm-abort-refuse: catch needs exception handling, which --exceptions=abort leaves out
p catch(:done) { throw :done, 1 }
