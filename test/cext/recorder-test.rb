require "json"
require "open3"
require "tmpdir"
require_relative "../../tools/cext-record"

ROOT = File.expand_path("../..", __dir__)
def check(ok, message)
  raise message unless ok
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
    "Ruby execution" => ['rb_funcall(rb_cObject, rb_intern("name"), 0);', "rb_funcall"],
    "constant lookup" => ['rb_const_get(rb_cObject, rb_intern("ENV"));', "rb_const_get"],
    "eval" => ['rb_eval_string("ENV[\\\"HOME\\\"]");', "rb_eval_string"],
    "runtime state" => ['rb_errinfo();', "rb_errinfo"],
    "environment" => ['getenv("HOME");', "getenv"],
    "clock" => ['time(0);', "time"],
    "file" => ['fopen("forbidden", "r");', "fopen"],
    "dynamic ID" => ['const char *name = "strip"; rb_intern(name);', "rb_intern"],
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
  check(CextRecord.scan(text) == [["strip"], [1]], "nested argument tokenization")
  puts "cext-recorder-test: pass"
end
