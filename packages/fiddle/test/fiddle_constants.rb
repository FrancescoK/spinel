# The constants programs read: type codes, sizes, alignments, dlopen flags.
require "fiddle"

p Fiddle::TYPE_VOID, Fiddle::TYPE_VOIDP, Fiddle::TYPE_CHAR, Fiddle::TYPE_SHORT, Fiddle::TYPE_INT,
  Fiddle::TYPE_LONG, Fiddle::TYPE_LONG_LONG, Fiddle::TYPE_FLOAT, Fiddle::TYPE_DOUBLE,
  Fiddle::TYPE_VARIADIC, Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_BOOL
p Fiddle::TYPE_SIZE_T, Fiddle::TYPE_SSIZE_T, Fiddle::TYPE_PTRDIFF_T, Fiddle::TYPE_INTPTR_T, Fiddle::TYPE_UINTPTR_T
p Fiddle::TYPE_UCHAR, Fiddle::TYPE_USHORT, Fiddle::TYPE_UINT, Fiddle::TYPE_ULONG, Fiddle::TYPE_ULONG_LONG
p Fiddle::TYPE_INT8_T, Fiddle::TYPE_UINT8_T, Fiddle::TYPE_INT16_T, Fiddle::TYPE_UINT16_T,
  Fiddle::TYPE_INT32_T, Fiddle::TYPE_UINT32_T, Fiddle::TYPE_INT64_T, Fiddle::TYPE_UINT64_T
p Fiddle::SIZEOF_CHAR, Fiddle::SIZEOF_SHORT, Fiddle::SIZEOF_INT, Fiddle::SIZEOF_LONG,
  Fiddle::SIZEOF_LONG_LONG, Fiddle::SIZEOF_FLOAT, Fiddle::SIZEOF_DOUBLE, Fiddle::SIZEOF_VOIDP,
  Fiddle::SIZEOF_SIZE_T, Fiddle::SIZEOF_CONST_STRING, Fiddle::SIZEOF_BOOL
p Fiddle::ALIGN_CHAR, Fiddle::ALIGN_SHORT, Fiddle::ALIGN_INT, Fiddle::ALIGN_LONG,
  Fiddle::ALIGN_DOUBLE, Fiddle::ALIGN_VOIDP
p Fiddle::RTLD_LAZY, Fiddle::RTLD_NOW, Fiddle::RTLD_GLOBAL > 0   # the flag's value is the host's
p Fiddle::Handle::RTLD_LAZY == Fiddle::RTLD_LAZY, Fiddle::Function::DEFAULT.is_a?(Integer)   # the ABI code is the host's
p Fiddle::DLError.ancestors.first(3), Fiddle::Error.superclass
p Fiddle::WINDOWS, Fiddle::NULL.null?, Fiddle::RUBY_FREE.class
