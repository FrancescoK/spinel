# A local the registration's path reads may be read by a String reader
# before it: the path stays the one the local was assigned.
path = File.join(__dir__, "autoload_path_read_lib")
p path.end_with?("lib")
autoload :PathRead, path
p PathRead.v
