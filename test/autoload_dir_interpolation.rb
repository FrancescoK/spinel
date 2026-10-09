# autoload with a "#{__dir__}/path" argument, the layout a gem's lib/x.rb
# uses to name its own files (rdoc's lib/rdoc.rb has 85 of them): the path is
# the file's own directory plus a literal, so it is loaded eagerly as a
# require_relative, the same as a plain literal path. Any other interpolation
# stays a computed path and is left alone.
require_relative "autoload_dir_interpolation/adi"
p Adi::Thing.hi
p Adi.name_of
p Adi::Other::DEEP
p Adi.late_class.name
raise "line numbers moved" unless __LINE__ == 11
