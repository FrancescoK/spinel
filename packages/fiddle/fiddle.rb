# Spinel bundled `fiddle` -- the stdlib's Fiddle API (Handle, Function,
# Pointer, Closure), so programs and gems written against CRuby's `fiddle`
# compile unchanged.
#
# Fiddle is a C extension over libffi and dlopen; this is its API in Ruby over
# the bundled `ffi` package's native layer (packages/ffi/sp_ffi.c), the way
# that package carries the ffi gem. Addresses are Integers on this side, a
# Pointer holds one, and a call's signature is whatever the Function was made
# with, so a library path or a symbol can be computed at run time.
#
# Like Fiddle, nothing here checks a pointer's bounds: `ptr[0, 9]` reads nine
# bytes whatever the pointer's size says. A pointer of size 0 is one whose size
# is not known.
require "ffi"

module Fiddle
  VERSION = "1.1.8"
  WINDOWS = false

  class Error < StandardError; end
  class DLError < Error; end
  class ClearedReferenceError < Error; end

  # Type codes: a negative one is the unsigned variant (LP64 hosts, the only
  # ones the ffi package is built for).
  TYPE_BOOL = 11
  TYPE_CHAR = 2
  TYPE_CONST_STRING = 10
  TYPE_DOUBLE = 8
  TYPE_FLOAT = 7
  TYPE_INT = 4
  TYPE_INT16_T = 3
  TYPE_INT32_T = 4
  TYPE_INT64_T = 5
  TYPE_INT8_T = 2
  TYPE_INTPTR_T = 5
  TYPE_LONG = 5
  TYPE_LONG_LONG = 6
  TYPE_PTRDIFF_T = 5
  TYPE_SHORT = 3
  TYPE_SIZE_T = -5
  TYPE_SSIZE_T = 5
  TYPE_UCHAR = -2
  TYPE_UINT = -4
  TYPE_UINT16_T = -3
  TYPE_UINT32_T = -4
  TYPE_UINT64_T = -5
  TYPE_UINT8_T = -2
  TYPE_UINTPTR_T = -5
  TYPE_ULONG = -5
  TYPE_ULONG_LONG = -6
  TYPE_USHORT = -3
  TYPE_VARIADIC = 9
  TYPE_VOID = 0
  TYPE_VOIDP = 1
  ALIGN_BOOL = 1
  ALIGN_CHAR = 1
  ALIGN_DOUBLE = 8
  ALIGN_FLOAT = 4
  ALIGN_INT = 4
  ALIGN_INT16_T = 2
  ALIGN_INT32_T = 4
  ALIGN_INT64_T = 8
  ALIGN_INT8_T = 1
  ALIGN_INTPTR_T = 8
  ALIGN_LONG = 8
  ALIGN_LONG_LONG = 8
  ALIGN_PTRDIFF_T = 8
  ALIGN_SHORT = 2
  ALIGN_SIZE_T = 8
  ALIGN_SSIZE_T = 8
  ALIGN_UINTPTR_T = 8
  ALIGN_VOIDP = 8
  SIZEOF_BOOL = 1
  SIZEOF_CHAR = 1
  SIZEOF_CONST_STRING = 8
  SIZEOF_DOUBLE = 8
  SIZEOF_FLOAT = 4
  SIZEOF_INT = 4
  SIZEOF_INT16_T = 2
  SIZEOF_INT32_T = 4
  SIZEOF_INT64_T = 8
  SIZEOF_INT8_T = 1
  SIZEOF_INTPTR_T = 8
  SIZEOF_LONG = 8
  SIZEOF_LONG_LONG = 8
  SIZEOF_PTRDIFF_T = 8
  SIZEOF_SHORT = 2
  SIZEOF_SIZE_T = 8
  SIZEOF_SSIZE_T = 8
  SIZEOF_UCHAR = 1
  SIZEOF_UINT = 4
  SIZEOF_UINT16_T = 2
  SIZEOF_UINT32_T = 4
  SIZEOF_UINT64_T = 8
  SIZEOF_UINT8_T = 1
  SIZEOF_UINTPTR_T = 8
  SIZEOF_ULONG = 8
  SIZEOF_ULONG_LONG = 8
  SIZEOF_USHORT = 2
  SIZEOF_VOIDP = 8

  RTLD_LAZY = FFI::Native.rtld(0)
  RTLD_NOW = FFI::Native.rtld(1)
  RTLD_GLOBAL = FFI::Native.rtld(2)

  FFI_TYPES = {
    0 => :void, 1 => :pointer, 2 => :char, 3 => :short, 4 => :int, 5 => :long,
    6 => :long_long, 7 => :float, 8 => :double, 10 => :string, 11 => :bool,
    -2 => :uchar, -3 => :ushort, -4 => :uint, -5 => :ulong, -6 => :ulong_long
  }

  def self.__ffi_type(code)
    t = FFI_TYPES[code]
    raise ::RuntimeError, "unknown type #{code}" if t.nil?
    t
  end

  # An Integer argument: a Float is truncated, anything else is a TypeError.
  def self.__int(v)
    return v if v.is_a?(Integer)
    return v.to_i if v.is_a?(Float)
    raise ::TypeError, "no implicit conversion of #{v.nil? ? "nil" : v.class} into Integer"
  end

  def self.__address(v)
    if v.nil? then 0
    elsif v.is_a?(Integer) then v
    elsif v.is_a?(Pointer) then v.to_i
    elsif v.is_a?(Closure) then v.to_i
    elsif v.is_a?(Function) then v.to_i
    elsif v.is_a?(Handle) then v.to_i
    elsif v.respond_to?(:to_ptr) then v.to_ptr.to_i
    else raise ::TypeError, "no implicit conversion of #{v.class} into Integer"
    end
  end

  # ---- memory ----

  def self.malloc(size) = FFI::Native.malloc(size)
  def self.realloc(addr, size) = FFI::Native.realloc(addr, size)

  def self.free(addr)
    FFI::Native.free(addr)
    nil
  end

  # The errno of the last Function#call, saved right after the native call
  # (what Fiddle does): the work between that call and the caller's read can
  # change the live errno.
  @last_error = 0

  def self.last_error = @last_error

  def self.last_error=(v)
    @last_error = v
  end

  # The address of libc's free: what a Pointer given RUBY_FREE calls.
  RUBY_FREE = FFI::Native.dlsym(0, "free")

  class Pointer
    # The memory's release, apart from the Pointer: a finalizer that reached
    # the Pointer would keep it alive.
    class Release
      def initialize(addr, func)
        @addr = addr
        @func = func
      end

      def run
        f = @func
        a = @addr
        @func = 0
        return false if f == 0 || a == 0
        if f == Fiddle::RUBY_FREE
          FFI::Native.free(a)
        else
          Function.new(f, [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID).call(a)
        end
        true
      end

      def disarm
        @func = 0
        nil
      end

      def collected
        run
        nil
      end
    end

    def self.__finalizer(rel) = proc { |_id| rel.collected }

    # A Pointer to `size` bytes of C memory that is not the collector's: freed
    # by `freefunc` when the Pointer is collected, or never.
    def self.malloc(size, freefunc = nil) = new(FFI::Native.malloc(size), size, freefunc)

    # The Pointer a value stands for: a String's bytes, an address, a Pointer.
    def self.to_ptr(val)
      if val.is_a?(Pointer) then new(val.to_i, val.size)
      elsif val.is_a?(String)
        p = new(FFI::Native.str_addr(val), val.bytesize)
        p.__hold(val)
        p
      elsif val.is_a?(Integer) then new(val)
      elsif val.respond_to?(:to_ptr) then val.to_ptr
      else raise ::TypeError, "no implicit conversion of #{val.class} into Fiddle::Pointer"
      end
    end

    def self.[](val) = to_ptr(val)

    def initialize(addr, size = 0, freefunc = nil)
      @addr = addr.is_a?(Pointer) ? addr.to_i : Integer(addr)
      @size = Fiddle.__int(size)
      @release = nil
      @freed = false
      @hold = nil
      self.free = freefunc if freefunc
    end

    def __hold(v)
      @hold = v
      nil
    end

    def to_i = @addr
    def to_int = @addr
    def size = @size

    def size=(v)
      @size = Fiddle.__int(v)
    end

    def null? = @addr == 0

    # The function that frees this memory, or nil.
    def free
      return nil if @release.nil?
      @free_func
    end

    def free=(f)
      addr = f.nil? ? 0 : Fiddle.__address(f)
      @release.disarm if @release
      if addr == 0
        @release = nil
        @free_func = nil
      else
        @release = Release.new(@addr, addr)
        ObjectSpace.define_finalizer(self, Pointer.__finalizer(@release))
        @free_func = f.is_a?(Function) ? f : Function.new(addr, [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)
      end
      @freed = false
      f
    end

    def call_free
      @freed = true if @release && @release.run
      nil
    end

    def freed? = @freed

    def +(n)
      n = Fiddle.__int(n)
      Pointer.new(@addr + n, @size - n)
    end

    def -(n)
      n = Fiddle.__int(n)
      Pointer.new(@addr - n, @size + n)
    end

    def ==(other) = other.is_a?(Pointer) && @addr == other.to_i
    def eql?(other) = self == other

    def <=>(other)
      return nil unless other.is_a?(Pointer)
      @addr <=> other.to_i
    end

    # The pointer this one points at.
    def ptr = Pointer.new(FFI::Native.get_int(@addr, FFI::Type::K_PTR))

    # ptr[i] is the byte at i (signed, as a C char); ptr[i, n] the n bytes.
    def [](off, len = nil)
      off = Fiddle.__int(off)
      raise DLError, "NULL pointer dereference" if @addr == 0
      if len.nil?
        FFI::Native.get_int(@addr + off, FFI::Type::K_I8)
      else
        len = Fiddle.__int(len)
        raise ::ArgumentError, "negative string size (or size too big)" if len < 0
        FFI::Native.read_bytes(@addr + off, len)
      end
    end

    # ptr[i] = byte; ptr[i, n] = string (n of its bytes)
    def []=(off, a, *rest)
      off = Fiddle.__int(off)
      raise DLError, "NULL pointer dereference" if @addr == 0
      if rest.empty?
        a = Fiddle.__int(a)
        FFI::Native.put_int(@addr + off, FFI::Type::K_I8, a & 255)
        a
      else
        b = rest[0]
        raise ::TypeError, "no implicit conversion of nil into Integer" if b.nil?
        len = Fiddle.__int(a)
        raise ::TypeError, "no implicit conversion of #{b.class} into String" unless b.is_a?(String)
        n = len < b.bytesize ? len : b.bytesize
        FFI::Native.write_bytes(@addr + off, b, 0, n) if n > 0
        b
      end
    end

    # The bytes up to the first NUL, or `len` of them.
    def to_s(len = nil)
      raise ::ArgumentError, "NULL pointer given" if @addr == 0
      len = len.nil? ? FFI::Native.strlen(@addr) : Fiddle.__int(len)
      raise ::ArgumentError, "negative string size (or size too big)" if len < 0
      FFI::Native.read_bytes(@addr, len)
    end

    # `len` bytes, or the pointer's size of them.
    def to_str(len = nil)
      len = len.nil? ? @size : Fiddle.__int(len)
      return "" if @addr == 0
      raise ::ArgumentError, "negative string size (or size too big)" if len < 0
      FFI::Native.read_bytes(@addr, len)
    end

    def inspect
      f = @release.nil? ? 0 : Fiddle.__address(@free_func)
      "#<Fiddle::Pointer:0x#{(object_id * 8).to_s(16).rjust(16, "0")} ptr=0x#{@addr.to_s(16).rjust(16, "0")} size=#{@size} free=0x#{f.to_s(16).rjust(16, "0")}>"
    end
  end

  NULL = Pointer.new(0)

  # ---- libraries ----

  class Handle
    RTLD_LAZY = Fiddle::RTLD_LAZY
    RTLD_NOW = Fiddle::RTLD_NOW
    RTLD_GLOBAL = Fiddle::RTLD_GLOBAL

    def initialize(lib = nil, flags = RTLD_LAZY | RTLD_GLOBAL)
      unless lib.nil? || lib.is_a?(String)
        raise ::TypeError, "no implicit conversion of #{lib.class} into String"
      end
      @handle = FFI::Native.dlopen(lib.nil? ? "" : lib, flags)
      raise DLError, FFI::Native.dlerror if @handle == 0
      @open = true
      @close_enabled = true
    end

    def self.__raw(h)
      handle = new(nil)
      handle.__set(h)
      handle
    end

    def __set(h)
      @handle = h
      nil
    end

    DEFAULT = __raw(FFI::Native.rtld(4))
    NEXT = __raw(FFI::Native.rtld(5))

    # The address of a symbol, or nil.
    def sym_defined?(name)
      raise DLError, "closed handle" unless @open
      a = FFI::Native.dlsym(@handle, name)
      a == 0 ? nil : a
    end

    def sym(name)
      a = sym_defined?(name)
      raise DLError, "unknown symbol \"#{name}\"" if a.nil?
      a
    end

    def [](name) = sym(name)

    def self.sym(name) = NEXT.sym(name)
    def self.[](name) = NEXT.sym(name)
    def self.sym_defined?(name) = NEXT.sym_defined?(name)

    def close
      raise DLError, "dlclose() called too many times" unless @open
      @open = false
      FFI::Native.dlclose(@handle)
    end

    def enable_close
      @close_enabled = true
      nil
    end

    def disable_close
      @close_enabled = false
      nil
    end

    def close_enabled? = @close_enabled

    def to_i = @handle
    def to_ptr = Pointer.new(@handle)
  end

  def self.dlopen(library) = Handle.new(library)

  # ---- calling C ----

  class Function
    DEFAULT = 1

    attr_reader :abi, :name

    # Function.new(address, [argument types], return type, abi = DEFAULT, name: nil)
    # A function that takes variadic arguments ends its types with TYPE_VARIADIC
    # and is called with a (type, value) pair for each of them.
    def initialize(ptr, args, ret_type, abi = DEFAULT, name: nil)
      raise ::TypeError, "wrong argument type #{args.class} (expected Array)" unless args.is_a?(Array)
      @addr = Fiddle.__address(ptr)
      @ret = ret_type
      @abi = abi
      @name = name
      @variadic = false
      fixed = []
      args.each_with_index do |a, i|
        if a == Fiddle::TYPE_VARIADIC
          raise ::ArgumentError, "Fiddle::TYPE_VARIADIC must be the last argument type: #{args.inspect}" if i != args.size - 1
          @variadic = true
        else
          fixed << a
        end
      end
      @args = fixed
      ptypes = []
      fixed.each { |a| ptypes << Fiddle.__ffi_type(a) }
      ptypes << :varargs if @variadic
      @ffi = FFI::Function.new(FFI::FunctionType.new(Fiddle.__ffi_type(ret_type), ptypes), FFI::Pointer.new(@addr))
    end

    def ptr = @addr
    def to_i = @addr

    def __convert(t, v)
      if t == Fiddle::TYPE_VOIDP
        v.is_a?(String) ? v : Fiddle.__address(v)
      elsif t == Fiddle::TYPE_CONST_STRING
        v.is_a?(String) || v.nil? ? v : Fiddle.__address(v)
      else
        v
      end
    end

    def call(*args)
      n = @args.size
      if @variadic
        if args.size < n
          raise ::ArgumentError, "wrong number of arguments (given #{args.size}, expected #{n}+)"
        end
        if (args.size - n).odd?
          raise ::ArgumentError, "variadic arguments must be type and value pairs: #{args.inspect}"
        end
      elsif args.size != n
        raise ::ArgumentError, "wrong number of arguments (given #{args.size}, expected #{n})"
      end
      conv = []
      i = 0
      while i < n
        conv << __convert(@args[i], args[i])
        i += 1
      end
      while i < args.size
        t = args[i]
        conv << Fiddle.__ffi_type(t)
        conv << __convert(t, args[i + 1])
        i += 2
      end
      r = @ffi.invoke(conv, nil)
      Fiddle.last_error = FFI::Native.errno
      if @ret == Fiddle::TYPE_VOIDP
        Pointer.new(r.nil? ? 0 : r.address)
      else
        r
      end
    end

    def to_proc = proc { |*a| call(*a) }
  end

  # A C function pointer to Ruby code: calls come back through `call`, which a
  # subclass defines (BlockCaller runs a block).
  class Closure
    attr_reader :args, :ctype

    def initialize(ctype, args, abi = Function::DEFAULT)
      @ctype = ctype
      @args = args
      @abi = abi
      @freed = false
      ptypes = []
      args.each { |a| ptypes << Fiddle.__ffi_type(a) }
      ftype = FFI::FunctionType.new(Fiddle.__ffi_type(ctype), ptypes)
      @ffi = FFI::Function.new(ftype, proc { |*a| __dispatch(a) })
    end

    def __dispatch(vals)
      conv = []
      vals.each_with_index do |v, i|
        if @args[i] == Fiddle::TYPE_VOIDP
          conv << Pointer.new(v.nil? ? 0 : v.address)
        else
          conv << v
        end
      end
      r = call(*conv)
      # Unlike ffi callbacks, Fiddle closures reject nil numeric returns.
      if r.nil?
        if @ctype == TYPE_FLOAT || @ctype == TYPE_DOUBLE
          FFI::Type.float_arg(r)
        elsif @ctype == TYPE_LONG_LONG
          raise ::TypeError, "no implicit conversion from nil"
        elsif @ctype < 0 || @ctype == TYPE_VOIDP
          Fiddle.__int(r)
        elsif @ctype == TYPE_CONST_STRING
          raise ::TypeError, "no implicit conversion of nil into String"
        elsif @ctype != TYPE_VOID && @ctype != TYPE_BOOL
          FFI::Type.int_arg(r)
        end
      end
      r.is_a?(Pointer) ? r.to_i : r
    end

    def to_i = @ffi.address

    # The closure's code lives as long as the program, which is what lets a C
    # library keep the pointer: this only marks it freed.
    def free
      @freed = true
      nil
    end

    def freed? = @freed

    class BlockCaller < Closure
      def initialize(ctype, args, abi = Function::DEFAULT, &block)
        super(ctype, args, abi)
        @block = block
      end

      def call(*args) = @block.call(*args)
    end
  end
end
