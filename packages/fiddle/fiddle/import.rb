# Fiddle::Importer: a module `extend`s it, loads libraries with dlload and
# declares C functions from their prototypes with extern.
#
#   module LibC
#     extend Fiddle::Importer
#     dlload Fiddle.dlopen(nil)
#     extern "size_t strlen(const char*)"
#   end
#   LibC.strlen("hello")   # => 5
#
# The functions are called through __ffi_call, as an `extend FFI::Library`
# module's are: the compiler sends a call of a name the module has no method
# for there (and a bare call, in a class that includes the module, through
# the registry). struct, union, value and bind -- which build classes and
# methods from data -- are not provided.
# The registry keeps the receiver: an including instance has no function
# table unless it supplies its own, just as with CRuby's module functions.
require "fiddle"

module Fiddle
  # The C prototype parser, as the fiddle gem's (fiddle/cparser).
  module CParser
    def parse_signature(signature, tymap=nil)
      tymap ||= {}
      case compact(signature)
      when /^(?:[\w\*\s]+)\(\*(\w+)\((.*?)\)\)(?:\[\w*\]|\(.*?\));?$/
        func, args = $1, $2
        return [func, TYPE_VOIDP, split_arguments(args).collect {|arg| parse_ctype(arg, tymap)}]
      when /^([\w\*\s]+[\*\s])(\w+)\((.*?)\);?$/
        ret, func, args = $1.strip, $2, $3
        return [func, parse_ctype(ret, tymap), split_arguments(args).collect {|arg| parse_ctype(arg, tymap)}]
      else
        raise(RuntimeError,"can't parse the function prototype: #{signature}")
      end
    end

    def parse_ctype(ty, tymap=nil)
      tymap ||= {}
      if ty.is_a?(Array)
        return [parse_ctype(ty[0], tymap), ty[1]]
      end
      ty = ty.gsub(/\Aconst\s+/, "")
      case ty
      when 'void'
        return TYPE_VOID
      when /\A(?:(?:signed\s+)?long\s+long(?:\s+int\s+)?|int64_t)(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_LONG_LONG)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_LONG_LONG
      when /\A(?:unsigned\s+long\s+long(?:\s+int\s+)?|uint64_t)(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_LONG_LONG)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_ULONG_LONG
      when /\Aunsigned\s+long(?:\s+int\s+)?(?:\s+\w+)?\z/,
           /\Aunsigned\s+int\s+long(?:\s+\w+)?\z/,
           /\Along(?:\s+int)?\s+unsigned(?:\s+\w+)?\z/,
           /\Aint\s+unsigned\s+long(?:\s+\w+)?\z/,
           /\A(?:int\s+)?long\s+unsigned(?:\s+\w+)?\z/
        return TYPE_ULONG
      when /\A(?:signed\s+)?long(?:\s+int\s+)?(?:\s+\w+)?\z/,
           /\A(?:signed\s+)?int\s+long(?:\s+\w+)?\z/,
           /\Along(?:\s+int)?\s+signed(?:\s+\w+)?\z/
        return TYPE_LONG
      when /\Aunsigned\s+short(?:\s+int\s+)?(?:\s+\w+)?\z/,
           /\Aunsigned\s+int\s+short(?:\s+\w+)?\z/,
           /\Ashort(?:\s+int)?\s+unsigned(?:\s+\w+)?\z/,
           /\Aint\s+unsigned\s+short(?:\s+\w+)?\z/,
           /\A(?:int\s+)?short\s+unsigned(?:\s+\w+)?\z/
        return TYPE_USHORT
      when /\A(?:signed\s+)?short(?:\s+int\s+)?(?:\s+\w+)?\z/,
           /\A(?:signed\s+)?int\s+short(?:\s+\w+)?\z/,
           /\Aint\s+(?:signed\s+)?short(?:\s+\w+)?\z/
        return TYPE_SHORT
      when /\A(?:signed\s+)?int(?:\s+\w+)?\z/
        return TYPE_INT
      when /\A(?:unsigned\s+int|uint)(?:\s+\w+)?\z/
        return TYPE_UINT
      when /\A(?:signed\s+)?char(?:\s+\w+)?\z/
        return TYPE_CHAR
      when /\Aunsigned\s+char(?:\s+\w+)?\z/
        return  TYPE_UCHAR
      when /\Aint8_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT8_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_INT8_T
      when /\Auint8_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT8_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_UINT8_T
      when /\Aint16_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT16_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_INT16_T
      when /\Auint16_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT16_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_UINT16_T
      when /\Aint32_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT32_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_INT32_T
      when /\Auint32_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT32_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_UINT32_T
      when /\Aint64_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT64_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_INT64_T
      when /\Auint64_t(?:\s+\w+)?\z/
        unless Fiddle.const_defined?(:TYPE_INT64_T)
          raise(RuntimeError, "unsupported type: #{ty}")
        end
        return TYPE_UINT64_T
      when /\Afloat(?:\s+\w+)?\z/
        return TYPE_FLOAT
      when /\Adouble(?:\s+\w+)?\z/
        return TYPE_DOUBLE
      when /\Asize_t(?:\s+\w+)?\z/
        return TYPE_SIZE_T
      when /\Assize_t(?:\s+\w+)?\z/
        return TYPE_SSIZE_T
      when /\Aptrdiff_t(?:\s+\w+)?\z/
        return TYPE_PTRDIFF_T
      when /\Aintptr_t(?:\s+\w+)?\z/
        return TYPE_INTPTR_T
      when /\Auintptr_t(?:\s+\w+)?\z/
        return TYPE_UINTPTR_T
      when /\Abool(?:\s+\w+)?\z/
        return TYPE_BOOL
      when /\*/, /\[[\s\d]*\]/
        return TYPE_VOIDP
      when "..."
        return TYPE_VARIADIC
      else
        ty = ty.split(' ', 2)[0]
        if( tymap[ty] )
          return parse_ctype(tymap[ty], tymap)
        else
          raise(DLError, "unknown type: #{ty}")
        end
      end
    end

    private

    private

    def split_arguments(arguments, sep=',')
      return [] if arguments.strip == 'void'
      arguments.scan(/([\w\*\s]+\(\*\w*\)\(.*?\)|[\w\*\s\[\]]+|\.\.\.)(?:#{sep}\s*|\z)/).collect {|m| m[0]}
    end

    def compact(signature)
      signature.gsub(/\s+/, ' ').gsub(/\s*([\(\)\[\]\*,;])\s*/, '\1').strip
    end
  end

  # Used internally by Fiddle::Importer
  class CompositeHandler
    def initialize(handlers)
      @handlers = handlers
    end

    def handlers = @handlers

    def sym(symbol)
      @handlers.each do |handle|
        if handle
          begin
            return handle.sym(symbol)
          rescue DLError
          end
        end
      end
      nil
    end

    def [](symbol) = sym(symbol)
  end

  class Function
    # how FFI__Registry's bare-call dispatch invokes a function
    def __ffi_invoke(args, blk, receiver)
      fns = receiver.instance_variable_get(:@func_map)
      raise NoMethodError, "undefined method '[]' for nil" if fns.nil?
      fns[@name.to_s].call(*args)
    end
  end

  module Importer
    include Fiddle
    include CParser
    extend Importer

    def type_alias = @type_alias
    private :type_alias

    def dlload(*libs)
      handles = []
      libs.each do |lib|
        if lib.nil?
          handles << nil
        elsif lib.is_a?(Handle)
          handles << lib
        elsif lib.respond_to?(:handlers)
          lib.handlers.each { |h| handles << h }
        else
          handles << Fiddle.dlopen(lib)
        end
      end
      @handler = CompositeHandler.new(handles)
      @func_map = {}
      @type_alias = {}
    end

    def handler = @handler
    def handlers = @handler ? @handler.handlers : []

    def typealias(alias_type, orig_type)
      @type_alias[alias_type] = orig_type
    end

    def sizeof(ty)
      case ty
      when String
        ty = parse_ctype(ty, type_alias).abs
        case ty
        when TYPE_CHAR then return SIZEOF_CHAR
        when TYPE_SHORT then return SIZEOF_SHORT
        when TYPE_INT then return SIZEOF_INT
        when TYPE_LONG then return SIZEOF_LONG
        when TYPE_FLOAT then return SIZEOF_FLOAT
        when TYPE_DOUBLE then return SIZEOF_DOUBLE
        when TYPE_VOIDP then return SIZEOF_VOIDP
        when TYPE_CONST_STRING then return SIZEOF_CONST_STRING
        when TYPE_BOOL then return SIZEOF_BOOL
        else
          return SIZEOF_LONG_LONG if ty == TYPE_LONG_LONG
          raise DLError, "unknown type: #{ty}"
        end
      end
      Pointer[ty].size
    end

    # Declares a function from its C prototype; calls of it on the module
    # (or, where the module is included, bare) reach it.
    def extern(signature, *opts)
      symname, ctype, argtype = parse_signature(signature, type_alias)
      opt = parse_bind_options(opts)
      f = import_function(symname, ctype, argtype, opt[:call_type])
      name = symname.gsub(/@.+/, "")
      # Keep the key a String while the parser's tuple is still untyped.
      @func_map[name.to_s] = f
      ::FFI__Registry.__add(self, name.to_sym, f)
      f
    end

    def import_function(name, ctype, argtype, call_type = nil)
      addr = handler.sym(name)
      raise DLError, "cannot find the function: #{name}()" unless addr
      Function.new(addr, argtype, ctype, Fiddle::Function::DEFAULT, name: name)
    end

    def import_symbol(name)
      addr = handler.sym(name)
      raise DLError, "cannot find the symbol: #{name}" unless addr
      Pointer.new(addr)
    end

    def __ffi_call(name, args, blk = nil, &b)
      fns = @func_map
      f = fns ? fns[name.to_s] : nil
      raise NoMethodError, "undefined method '#{name}' for #{self}" unless f
      f.call(*args)
    end

    def __ffi_attached?(name)
      fns = @func_map
      fns ? fns.key?(name.to_s) : false
    end

    def parse_bind_options(opts)
      h = {}
      while opt = opts.shift
        case opt
        when :stdcall, :cdecl
          h[:call_type] = opt
        when :carried, :temp, :temporal, :bind
          h[:callback_type] = opt
          h[:carrier] = opts.shift
        else
          h[opt] = true
        end
      end
      h
    end
    private :parse_bind_options
  end
end
