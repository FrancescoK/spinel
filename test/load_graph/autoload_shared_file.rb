# Two registrations name one file, which defines both constants: defined?
# answers "constant" for each while it is pending, nil for both inside the
# file until it assigns them, and the first read runs the file once.
autoload :SharedA, File.join(__dir__, "autoload_shared_file_lib")
autoload :SharedB, File.join(__dir__, "autoload_shared_file_lib")
p [defined?(SharedA), defined?(SharedB)]
p SharedB
p [defined?(SharedA), defined?(SharedB)]
p SharedA
