require "fiddle/import"

module LibC
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  typealias "mysize", "size_t"
  extern "mysize strlen(const char*)"
  extern "int abs(int x)"
  extern "long labs(long)"
  extern "double sqrt(double)"
  extern "char *strchr(const char *s, int c)"
  extern "int atoi(const char*)"
  extern "int snprintf(char*, size_t, const char*, ...)"
end

p LibC.strlen("hello")
p LibC.abs(-7)
p LibC.labs(-1234567890123)
p LibC.sqrt(2.0)
p LibC.atoi("42x")
r = LibC.strchr("hello", 108)
p r.class, r.to_s
buf = Fiddle::Pointer.malloc(32)
LibC.snprintf(buf, 32, "%d-%s", Fiddle::TYPE_INT, 5, Fiddle::TYPE_VOIDP, "x")
p buf.to_s
p LibC.sizeof("int"), LibC.sizeof("char*"), LibC.sizeof("long long"), LibC.sizeof("mysize")

begin
  LibC.extern "int no_such_function_xyz(int)"
rescue Fiddle::DLError => e
  puts "DLError"
end
begin
  LibC.extern "garbage"
rescue RuntimeError => e
  puts e.message
end
begin
  LibC.extern "int f(blob_t)"
rescue Fiddle::DLError => e
  puts e.message
end
begin
  module Bad; extend Fiddle::Importer; dlload "libnonexistent_zzz.so"; end
rescue Fiddle::DLError => e
  puts "DLError dlopen"
end
