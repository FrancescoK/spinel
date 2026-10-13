# spinel: gc-stress
# File.basename(path, suffix) strips the suffix from the base name
# sp_file_basename answers, a new String it held unrooted while it made the
# stripped copy, and File.extname read the extension out of its path after
# the copy allocated, with the path, an interpolation, held only in the
# call's argument: under SPINEL_GC_STRESS=2 both read freed bytes.
n = 3
p File.basename("/a/b#{n}.rb", ".rb"), File.basename("/x/y#{n}.tar.gz", ".*")
p File.basename("dir/file#{n}.txt", ".txt"), File.basename("#{n}.c", ".c")
p File.basename("/k/keep#{n}.rb", ".py")
p File.extname("/a/b#{n}.rb"), File.extname("c#{n}.tar.gz"), File.extname(".rc#{n}")
