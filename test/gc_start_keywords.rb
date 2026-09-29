# GC.start takes CRuby's keyword hints (ruby-vips runs GC.start full_mark: false).
gen = true
GC.start full_mark: false
GC.start(full_mark: gen, immediate_sweep: true)
GC.start
puts :ok
