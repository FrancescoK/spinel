# Spinel bundled `json` -- a typed native binding (Path B).
#
# JSON is backed by C in lib/sp_json.c. Rather than the compiler hardcoding
# the dispatch, this package declares the binding: `native_lib` names the
# strict-require feature, and each `native_func` maps a Ruby method to a C
# symbol with spinel-typed args/return. The compiler reads these at analyze
# time and emits direct, typed C calls (JSON.generate(x) -> sp_json_val(<boxed
# x>)), no FFI boxing.
#
# native_func :name, [arg_specs], ret_spec, "c_symbol"
#   specs: any (sp_RbVal) | string | int | float | bool | nil
module JSON
  native_lib "json"
  native_obj "packages/json/sp_json.o"   # carried C, linked only when required
  native_obj_reflect                     # gates the generated #to_json bridge (sp_obj_to_json_fn)
  native_func :generate, [:any], :string, "sp_json_val"
  native_func :__dump,   [:any, :int], :string, "sp_json_dump"
  native_func :parse,    [:string], :any,  "sp_json_parse"
  native_func :pretty_generate, [:any], :string, "sp_json_pretty"

  # JSON.dump(obj[, io][, limit]), as CRuby's: an Integer second argument is
  # the nesting limit (past it, ArgumentError "exceed depth limit"), an IO
  # one gets the text written and is the answer; there is no 100-level cap
  # but that limit, and NaN / Infinity are written out (dump's allow_nan).
  def self.dump(obj, io = nil, limit = nil)
    if limit.nil? && io.is_a?(Integer)
      limit = io
      io = nil
    end
    text = __dump(obj, limit || 0)
    return text if io.nil?
    io.write(text)
    io
  end
end
