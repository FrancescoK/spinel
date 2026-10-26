require "json"
require "open3"
require "tmpdir"
require_relative "../../tools/cext-record"

ROOT = File.expand_path("../..", __dir__)
def check(ok, message)
  raise message unless ok
end
# The bridge scan runs over preprocessed extension tokens, including helper
# functions that Init does not execute.
ids, arities, bridge = CextRecord.scan(<<~C)
  rb_intern("strip"); rb_intern2("split_extra", 5);
  rb_funcallv(obj, id, 2, argv);
  rb_block_call(obj, id, 1, argv, callback, data);
  rb_iv_get(obj, "@flags"); rb_iv_set(obj, "@paths", value);
  rb_ivar_get(obj, rb_intern("@other"));
  rb_const_get(klass, rb_intern("Error"));
  rb_eval_string("ENV['FLAG']");
C
check(ids == %w[@other Error split strip], "bridge literal IDs")
check(arities == [1, 2], "vector/block-call arities")
check(bridge == {"ivars" => %w[@flags @other @paths], "evals" => ["ENV['FLAG']"], "constant_reads" => true, "computed_ids" => false, "spread_sends" => false}, "bridge scan operations")
check(CextRecord.scan("rb_funcall(obj, sp_cext_scanned_sym2id(name), 0);")[2]["computed_ids"], "SYM2ID marks computed IDs")
check(CextRecord.scan("rb_funcallv(obj, id, argc, argv);")[2]["spread_sends"], "a computed rb_funcallv count marks spread sends")
check(CextRecord.scan("rb_apply(obj, rb_intern(\"call\"), params);")[2]["spread_sends"], "rb_apply marks spread sends")
check(!CextRecord.scan("rb_funcallv(obj, id, 2, argv);")[2]["spread_sends"], "a literal rb_funcallv count is no spread send")
{
  'rb_intern2(name, 2)' => "rb_intern",
  'rb_intern2("abc", size)' => "length",
  'rb_intern2("abc", 4)' => "exceeds",
  'rb_funcall(obj, id, argc)' => "arity",
  'rb_apply(obj, id)' => "argument count",
  'rb_block_call(obj, id, 1, argv)' => "argument count",
  'rb_iv_get(obj, name)' => "literal",
  'rb_iv_set(obj, "@@bad", value)' => "instance variable",
  'rb_eval_string(code)' => "literal",
  'rb_to_id(value)' => "runtime-computed",
  'rb_check_id(&value)' => "runtime-computed",
  'rb_sym2id(value)' => "runtime-computed"
}.each do |source, diagnostic|
  begin
    CextRecord.scan(source)
    raise "scanner unexpectedly accepted #{source}"
  rescue CextRecord::Refusal => e
    check(e.message.include?(diagnostic), "scanner wrong diagnostic: #{e.message}")
  end
end

Dir.mktmpdir("cext-recorder-test-") do |dir|
  manifest = File.join(dir, "manifest.json")
  ruby = File.join(dir, "declarations.rb")
  archive = File.join(dir, "extension.a")
  options = {name: "sample", init: "Init_sample", output: manifest, declarations: ruby, object_archive: archive,
             sources: [File.join(ROOT, "test/cext/recorder/definitions.c")]}
  m = CextRecord.record(**options)
  first = File.binread(manifest); first_ruby = File.binread(ruby)
  CextRecord.record(**options)
  check(first == File.binread(manifest), "manifest contains nondeterministic data")
  check(first_ruby == File.binread(ruby), "declarations contain nondeterministic data")
  check(CextRecord.command("ar", "t", archive).lines.map(&:strip).select { |n| n.end_with?(".o") } == ["extension0.o"], "retained extension object archive")
  first_archive = File.binread(archive)
  check(m["literal_ids"] == %w[sample strip], "macro/adjacent string ID scan")
  check(m["funcall_arities"] == [0], "funcall arity scan")
  defs = m["definitions"]
  check(defs.count { |d| d["kind"] == "method" } == 7, "method definitions")
  check(defs.select { |d| d.key?("function") }.map { |d| d["function"] } == (0..7).to_a, "function binding order")
  constants = defs.select { |d| d["kind"] == "constant" }.to_h { |d| [d["name"], d["value"]] }
  check(constants["ANSWER"] == {"type"=>"integer", "value"=>42}, "macro-defined constant")
  check(constants["SAME"]["value"] == true, "reopened module identity")
  check(constants["BYTES"]["hex"] == "7800ff", "binary/NUL string data")
  check(constants["BYTES"] == constants["SAME_BYTES"] && constants["BYTES"]["frozen"], "constant string identity/frozen state")
  syntax, status = Open3.capture2(RbConfig.ruby, "-c", ruby)
  check(status.success? && syntax.include?("Syntax OK"), "invalid declaration Ruby")

  refusals = {
    "object class during Init" => ['rb_obj_class(rb_cObject);', "rb_obj_class"],
    "class name during Init" => ['rb_class2name(rb_cObject);', "rb_class2name"],
    "number conversion during Init" => ['NUM2LONG(INT2FIX(1));', "NUM2LONG"],
    "value type during Init" => ['TYPE(rb_cObject);', "rb_type"],
    "hash read during Init" => ['rb_hash_aref(rb_cObject, Qnil);', "rb_hash_aref"],
    "Ruby execution" => ['rb_funcall(rb_cObject, rb_intern("name"), 0);', "rb_funcall"],
    "invalid constant lookup" => ['rb_const_get(rb_cObject, rb_intern("lower"));', "ASCII constant names"],
    "eval" => ['rb_eval_string("ENV[\\\"HOME\\\"]");', "rb_eval_string"],
    "runtime state" => ['rb_errinfo();', "rb_errinfo"],
    "environment" => ['getenv("HOME");', "getenv"],
    "clock" => ['time(0);', "time"],
    "file" => ['fopen("forbidden", "r");', "fopen"],
    "dynamic ID" => ['const char *name = "strip"; rb_intern(name);', "rb_intern"],
    "computed string ID" => ['extern ID rb_check_id(VALUE *); rb_check_id(0);', "runtime-computed"],
    "dynamic eval" => ['const char *code = "1"; rb_eval_string(code);', "literal"],
    "dynamic ivar" => ['const char *name = "@x"; rb_iv_get(rb_cObject, name);', "literal"],
    "hidden ivar during Init" => ['rb_iv_set(rb_cObject, "-state", Qnil);', "rb_iv_set"],
    "Ruby ivar defined?" => ['rb_ivar_defined(rb_cObject, rb_intern("@x"));', "hidden instance variable"],
    "bad hidden ivar" => ['rb_iv_get(rb_cObject, "-");', "invalid literal instance variable"],
    "catch during Init" => ['rb_catch("tag", 0, Qnil);', "rb_catch"],
    "vector call during Init" => ['rb_funcallv(rb_cObject, rb_intern("name"), 0, 0);', "rb_funcallv"],
    "API address" => ['ID (*intern)(const char *) = rb_intern; intern("strip");', "rb_intern"],
    "dynamic arity" => ['int argc = 0; rb_funcall(rb_cObject, rb_intern("name"), argc);', "rb_funcall"],
    "layout" => ['RBASIC(rb_cObject);', "object layout"],
    "late freeze" => ['VALUE m=rb_define_module("M"); VALUE s=rb_str_new_cstr("x"); rb_define_const(m,"S",s); rb_str_freeze(s);', "rb_str_freeze"],
    "wrong superclass" => ['rb_define_class("C",rb_cObject); rb_define_class("C",rb_cString);', "superclass mismatch"],
    "wrong kind" => ['rb_define_class("C",rb_cObject); rb_define_module("C");', "kind mismatch"],
    "unknown VALUE" => ['rb_define_const(rb_cObject,"X",(VALUE)0x1000);', "unknown recorder VALUE"],
    "constant alias definition" => ['VALUE c=rb_define_class("C",rb_cObject); rb_define_const(rb_cObject,"Alias",c); rb_define_class("Alias",rb_cObject);', "constant aliases"],
    "nonclass constant definition" => ['rb_define_const(rb_cObject,"C",Qtrue); rb_define_class("C",rb_cObject);', "expected a recorded class"],
    "bad constant name" => ['rb_define_const(rb_cObject,"lower",Qnil);', "ASCII constant names"],
    "hung Init" => ['for (;;) {}', "exceeded 10 seconds"],
    "unknown API" => ['extern void unavailable(void); unavailable();', "unavailable"]
  }
  refusals.each do |label, (body, expected)|
    source = File.join(dir, "refused.c")
    File.write(source, "#include \"ruby.h\"\n#include <stdlib.h>\n#include <stdio.h>\n#include <time.h>\nvoid Init_sample(void) { #{body} }\n")
    begin
      CextRecord.record(**options.merge(sources: [source]))
      raise "#{label} unexpectedly accepted"
    rescue CextRecord::Refusal => e
      check(e.message.include?(expected), "#{label}: wrong diagnostic #{e.message}")
    end
    check(File.binread(manifest) == first && File.binread(ruby) == first_ruby && File.binread(archive) == first_archive, "#{label}: failed build replaced artifacts")
  end

  # Calls hidden in local macros and cross-TU helpers must be checked too.
  a = File.join(dir, "a.c"); b = File.join(dir, "b.c")
  File.write(a, '#include "ruby.h"' + "\nextern void helper(void); void Init_sample(void) { helper(); }\n")
  File.write(b, "#include <stdlib.h>\nvoid helper(void) { getenv(\"HOME\"); }\n")
  begin
    CextRecord.record(**options.merge(sources: [a,b]))
    raise "cross-TU environment access accepted"
  rescue CextRecord::Refusal => e
    check(e.message.include?("getenv"), "cross-TU diagnostic")
  end
  File.write(b, '#include "ruby.h"' + "\nvoid helper(void) { rb_define_module(\"Helper\"); }\n")
  check(CextRecord.record(**options.merge(sources: [a,b]))["definitions"].first["path"] == "Helper", "cross-TU definition")

  # A macro-produced literal survives preprocessing; comments do not create IDs.
  text = "# 1 \"fixture.c\"\nrb_intern(\"str\" \"ip\"); rb_funcall(v, id, 1, (a,b));"
  check(CextRecord.scan(text).first(2) == [["strip"], [1]], "nested argument tokenization")
  puts "cext-recorder-test: pass"
end
