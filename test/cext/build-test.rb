require 'tmpdir'
require 'fileutils'
require_relative '../../tools/cext-build'
Dir.mktmpdir('spinel-cext-build-') do |root|
  File.write(File.join(root, 'spin.toml'), <<~TOML)
    [package]
    name = "build-test"
    [cext.sample]
    init = "Init_sample"
    sources = ["sample.c"]
    require = "sample"
  TOML
  header = File.join(root, 'answer.h')
  File.write(header, "#define ANSWER 7\n")
  source = File.join(root, 'sample.c')
  File.write(source, <<~C)
    #include <ruby.h>
    #include "answer.h"
    static VALUE answer(VALUE self) { (void)self; return INT2FIX(ANSWER); }
    void Init_sample(void) {
      VALUE m = rb_define_module("BuildSample");
      rb_define_singleton_method(m, "answer", answer, 0);
    }
  C
  recipe = CextBuild.recipes(root).fetch(0)
  cache = File.join(root, 'cache')
  first = CextBuild.build(recipe, cache: cache)
  timestamp = File.mtime(first.fetch('archive'))
  second = CextBuild.build(recipe, cache: cache)
  raise 'cache hit rebuilt the extension' unless first == second && File.mtime(second.fetch('archive')) == timestamp
  flagged = CextBuild.build(recipe, cache: cache, cc: ENV.fetch('CC', 'cc') + ' -DCExtBuildFlag=1')
  raise 'compiler command flags did not invalidate cache' if flagged == first
  File.write(header, "#define ANSWER 9\n")
  changed = CextBuild.build(recipe, cache: cache)
  raise 'included header did not invalidate cache' if changed == first
  mt = File.join(changed.fetch('directory'), 'extension_mt.a')
  File.delete(mt)
  CextBuild.build(recipe, cache: cache)
  raise 'missing threaded archive was reused' unless File.file?(mt)
  File.write(source, <<~C)
    #include <ruby.h>
    #include <unistd.h>
    static VALUE pid_value(VALUE self) { (void)self;return LL2NUM(getpid()); }
    void Init_sample(void) {
      VALUE m=rb_define_module("BuildSample");
      rb_define_singleton_method(m,"pid",pid_value,0);
    }
  C
  native = CextBuild.build(recipe, cache: cache)
  raise 'runtime native import was not retained' unless File.file?(native.fetch('archive'))
  File.write(source, File.read(source).sub('VALUE m=rb_define_module', '(void)getpid(); VALUE m=rb_define_module'))
  begin
    CextBuild.build(recipe, cache: cache)
    raise 'native library call during Init was accepted'
  rescue CextBuild::Refusal => error
    raise unless error.message.include?('getpid') && error.message.include?('not allowed during Init')
  end
  File.write(source, <<~C)
    #define _POSIX_C_SOURCE 200809L
    #include <ruby.h>
    #include <string.h>
    #include <errno.h>
    static VALUE error_text(VALUE self) {
      (void)self; char buffer[256];
      (void)strerror_r(EINVAL, buffer, sizeof(buffer));
      return rb_str_new_cstr(buffer);
    }
    void Init_sample(void) {
      VALUE m = rb_define_module("BuildSample");
      rb_define_singleton_method(m, "error_text", error_text, 0);
    }
  C
  CextBuild.build(recipe, cache: cache)
  library_source=File.join(root,'library.c')
  library_object=File.join(root,'library.o')
  library_archive=File.join(root,'library.a')
  File.write(library_source,'int native_setup(void){return 7;} int native_runtime(void){return 9;}')
  CextRecord.command('cc','-c',library_source,'-o',library_object)
  CextRecord.command('ar','rcs',library_archive,library_object)
  File.write(source, <<~C)
    #include <ruby.h>
    extern int native_setup(void), native_runtime(void);
    static VALUE runtime(VALUE self) { (void)self;return INT2FIX(native_runtime()); }
    void Init_sample(void) {
      VALUE m=rb_define_module("BuildSample");
      rb_define_const(m,"SETUP",INT2FIX(native_setup()));
      rb_define_singleton_method(m,"runtime",runtime,0);
    }
  C
  initializer_recipe=recipe.merge('libs'=>[library_archive],'init_imports'=>['native_setup'])
  initialized=CextBuild.build(initializer_recipe,cache:cache)
  manifest=JSON.parse(File.read(File.join(initialized.fetch('directory'),'manifest.json')))
  setup=manifest.fetch('definitions').find { |definition| definition['kind']=='constant' }
  raise 'native initializer was replaced' unless setup.fetch('value').fetch('value')==7
  begin
    CextBuild.build(initializer_recipe.merge('init_imports'=>[]),cache:cache)
    raise 'undeclared native initializer accepted'
  rescue CextBuild::Refusal => error
    raise unless error.message.include?('native_setup') && error.message.include?('not allowed during Init')
  end
  File.write(source, <<~C)
    #include <ruby.h>
    void Init_sample(void) {
      VALUE m = rb_define_module("BuildSample");
    #ifdef SP_THREADS
      rb_define_const(m, "THREADED", Qtrue);
    #else
      rb_define_const(m, "THREADED", Qfalse);
    #endif
    }
  C
  begin
    CextBuild.build(recipe, cache: cache)
    raise 'different Init declarations were accepted'
  rescue CextBuild::Refusal => error
    raise unless error.message.include?('declarations differ')
  end
end
puts 'C extension builder: variants, cache, dependencies and Init refusal passed'
