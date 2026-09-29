# autoload with a literal path: the whole program is compiled, so the file
# is loaded eagerly (after the module body that names it).
$LOAD_PATH.unshift File.join(__dir__, "autoload_literal_path")
require_relative "autoload_literal_path/alp"
p Alp::Thing.hi
p Alp.name_of
