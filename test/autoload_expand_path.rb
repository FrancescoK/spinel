# autoload with a `File.expand_path('path', __dir__)` argument: the file
# beside the one naming it, loaded eagerly as a require_relative, the same
# as "#{__dir__}/path". In a required file the name may be a local, a
# loop's over the names one file defines
# (`%w[A B].each { |n| autoload n, File.expand_path(...) }`): that file is
# loaded once. The constants are those CRuby's lazy loading defines; a
# program that asks autoload? or lists the constants before their first use
# would see them already loaded.
require_relative "autoload_expand_path/aep"
p Aep::INDEX
p Aep::FIRST, Aep::SECOND
p Aep::LIST
p Aep.first_plus
raise "line numbers moved" unless __LINE__ == 14
