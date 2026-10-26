x = "lib"
z = 3.5
puts x
puts defined?(y).inspect
puts z
k = 7
[1, 2].each { |i| puts i + k }
$lib_proc = ->(n) { n * k }
