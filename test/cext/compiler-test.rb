require 'fileutils'
require 'tmpdir'
require 'open3'
require 'rbconfig'
require_relative '../../tools/cext-record'
ROOT = File.expand_path('../..', __dir__)
def command(*args, env: {}, chdir: ROOT)
  out, err, status = Open3.capture3(env, *args, chdir: chdir)
  raise "#{args.join(' ')}\n#{out}#{err}" unless status.success?
  out
end
Dir.mktmpdir('spinel-cext-compiler-') do |tmp|
  CextRecord.record(name: 'sample', init: 'Init_sample',
    sources: [File.join(ROOT, 'test/cext/compiler/sample.c')],
    output: File.join(tmp, 'sample.json'), declarations: File.join(tmp, 'sample.rb'),
    object_archive: File.join(tmp, 'sample.a'))
  FileUtils.cp(File.join(ROOT, 'test/cext/compiler/program.rb'), File.join(tmp, 'program.rb'))
  exe = File.join(tmp, 'program')
  command(File.join(ROOT, 'bin/spinel'), File.join(tmp, 'program.rb'), '--link', File.join(tmp, 'sample.a'), '-o', exe)
  c_file = File.join(tmp, 'program.c')
  command(File.join(ROOT, 'bin/spinel'), '-c', '--no-line-map', File.join(tmp, 'program.rb'), '-o', c_file)
  c_text = File.read(c_file)
  raise 'an unrelated Array lost its typed representation' unless c_text.match?(/sp_IntArray\s*\*\s*(?:const\s+)?lv_untouched/)
  raise 'a fresh map widened its unrelated source' unless c_text.match?(/sp_IntArray\s*\*\s*(?:const\s+)?lv_source/ )
  actual = command(exe)
  command(File.join(ROOT, 'bin/spinel'), File.join(tmp, 'program.rb'), '--share-strings', '--link', File.join(tmp, 'sample.a'), '-o', exe + '-shared')
  shared = command(exe + '-shared')
  raise 'shared String mode changed the output' unless shared == actual
  ['SPINEL_GC_STRESS', 'SPINEL_GC_MINOR', 'SPINEL_GC_SLAB'].each do |mode|
    value = mode == 'SPINEL_GC_SLAB' ? '0' : '1'
    stressed = command(exe, env: {mode => value, 'SPINEL_GC_VERIFY_GEN' => '1'})
    raise "#{mode} changed the output" unless stressed == actual
  end
  {
    '__cext_extension("bad", "Init_bad", 2)' => 'manifest version',
    '__cext_extension("bad", "Init_bad", 1); __cext_class("Bad", "Object"); __cext_method("Bad", "m", "instance", "public", 16, 0)' => 'arity',
    '__cext_extension("bad", "Init_bad", 1); __cext_allocator("Missing", 0)' => 'manifest class',
    '__cext_extension("bad", "Init_bad", 1); __cext_unknown(0)' => 'unknown C extension declaration'
  }.each_with_index do |(source, reason), i|
    file = File.join(tmp, "refusal#{i}.rb")
    File.write(file, source)
    out, err, status = Open3.capture3(File.join(ROOT, 'bin/spinel'), '-c', file, '-o', File.join(tmp, "refusal#{i}.c"))
    raise "missing refusal #{reason}: #{out}#{err}" if status.success? || !err.include?(reason)
  end
  native = File.join(tmp, 'cruby')
  FileUtils.mkdir_p(native)
  FileUtils.cp(File.join(ROOT, 'test/cext/compiler/sample.c'), File.join(native, 'sample.c'))
  FileUtils.cp(File.join(ROOT, 'test/cext/compiler/program.rb'), File.join(native, 'program.rb'))
  command(RbConfig.ruby, '-rmkmf', '-e', 'create_makefile("sample")', chdir: native)
  command('make', chdir: native)
  expected = command(RbConfig.ruby, File.join(native, 'program.rb'))
  raise "CRuby differs\nexpected:\n#{expected}\nactual:\n#{actual}" unless actual == expected
end
puts 'C extension compiler bridge: CRuby oracle and GC modes passed'
