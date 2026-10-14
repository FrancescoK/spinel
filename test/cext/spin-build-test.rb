require 'tmpdir'
require 'fileutils'
require 'open3'
ROOT = File.expand_path('../..', __dir__)
Dir.mktmpdir('spinel-spin-cext-') do |project|
  FileUtils.mkdir_p(File.join(project, 'bin'))
  FileUtils.cp(File.join(ROOT, 'test/cext/threads/sample.c'), File.join(project, 'sample.c'))
  File.write(File.join(project, 'native.c'), 'int unused_pkgconfig_probe(void) { return 1; }')
  File.write(File.join(project, 'helper.src'), 'int build_probe(void) { return 7; }')
  run_cc = ENV.fetch('CC', 'cc').split
  _out, error, status = Open3.capture3(*run_cc, '-x', 'c', '-c', File.join(project, 'helper.src'), '-o', File.join(project, 'system.o'))
  raise error unless status.success?
  _out, error, status = Open3.capture3('ar', 'rcs', File.join(project, 'system.a'), File.join(project, 'system.o'))
  raise error unless status.success?
  FileUtils.mkdir_p(File.join(project, 'vendor'))
  FileUtils.cp(File.join(project, 'helper.src'), File.join(project, 'vendor/helper.src'))
  File.write(File.join(project, 'vendor/build.sh'), "mkdir -p lib\n${CC:-cc} -x c -c helper.src -o lib/probe.o\nar rcs lib/probe.a lib/probe.o\n")
  program = File.read(File.join(ROOT, 'test/cext/threads/program.rb')).sub('require_relative', 'require')
  File.write(File.join(project, 'bin/main.rb'), program)
  File.write(File.join(project, 'spin.toml'), <<~TOML)
    [package]
    name = "cext-project"
    sources = ["native.c"]
    [[build]]
    workdir = "vendor"
    command = "sh build.sh"
    artifacts = ["lib/probe.a"]
    [native]
    pkg_config = ["spinel_missing_pkgconfig_fixture"]
    libs = [#{File.join(project, 'system.a').dump}, "${build.out}/lib/probe.a"]
    [cext.cxl_sample]
    init = "Init_cxl_sample"
    sources = ["sample.c"]
    libs = ["${build.out}/lib/probe.a"]
  TOML
  env = {'SPIN_NATIVE_CACHE' => File.join(project, 'cache'), 'SPINEL_WORKERS' => '4', 'SPIN_ALLOW_NATIVE_BUILD' => '1'}
  spin = File.join(ROOT, 'bin/spin')
  flags, error, status = Open3.capture3(env, spin, 'flags', chdir: project)
  raise "flags failed: #{error}" unless status.success?
  raise 'extension source was treated as undeclared native C' if error.include?('not named by')
  raise 'missing pkg-config metadata did not warn' unless error.include?('compiling without its flags')
  raise 'extension archive missing from flags' unless flags.include?('extension.a')
  out, error, status = Open3.capture3(env, spin, 'run', 'main', chdir: project)
  raise "spin run failed: #{out}#{error}" unless status.success?
  raise "wrong output: #{out}" unless out.lines.last == "80\n"
  out, error, status = Open3.capture3(env, spin, 'run', 'main', chdir: project)
  raise "cached spin run failed: #{out}#{error}" unless status.success? && out.lines.last == "80\n"
end
puts 'spin C extension build: declarations, threaded linking and cached run passed'
