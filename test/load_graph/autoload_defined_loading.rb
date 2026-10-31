# Inside the file an autoload is running, its constant is not defined until
# the file assigns it: defined? answers nil there, as CRuby does, and a
# guard on it assigns.
autoload :LoadingConst, File.join(__dir__, "autoload_defined_loading_lib")
p defined?(LoadingConst)
p LoadingConst
p defined?(LoadingConst)
p LoadingClass.v
