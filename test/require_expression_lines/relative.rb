# A nested require keeps the required file's own coordinates.
p [File.basename(__FILE__), __LINE__]
p require_relative("nested")
p [File.basename(__FILE__), __LINE__]
