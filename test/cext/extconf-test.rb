require 'tmpdir'
require 'fileutils'
require_relative '../../tools/cext-extconf'
require_relative '../../tools/cext-record'

Dir.mktmpdir('spinel-extconf-test-') do |dir|
  File.write(File.join(dir, 'sample.c'), 'void Init_sample(void) {}')
  makefile = File.join(dir, 'Makefile')
  File.write(makefile, <<~MAKE)
    TARGET = sample
    target_prefix = /nested
    srcdir = .
    SRCS = sample.c
    rubyhdrdir = /host/ruby/include
    hdrdir = $(rubyhdrdir)
    rubyarchhdrdir = /host/ruby/arch
    arch_hdrdir = $(rubyarchhdrdir)
    INCFLAGS = -I. -I$(hdrdir) -I$(arch_hdrdir)
    CPPFLAGS = -DEXAMPLE=7
    CFLAGS = -arch arm64 -O3 -fno-fast-math -ggdb3 -Wall -fstack-clash-protection -fcf-protection -ffile-prefix-map=/build=/src
    LOCAL_LIBS = vendor/libsample.a
    LIBS = -lssl -lcrypto
    DLDFLAGS = -shared -L vendor
  MAKE
  recipe = CextExtconf.recipe(makefile)
  raise 'wrong require feature' unless recipe.fetch('require') == 'nested/sample'
  raise 'wrong source path' unless recipe.fetch('sources') == [File.join(dir, 'sample.c')]
  raise 'host Ruby headers leaked' if recipe.fetch('cflags').any? { |flag| flag.include?('/host/ruby') }
  raise 'extension definition lost' unless recipe.fetch('cflags').include?('-DEXAMPLE=7')
  raise 'native library path lost' unless recipe.fetch('libs').include?(File.join(dir, 'vendor/libsample.a'))
  raise 'library search path lost' unless recipe.fetch('libs').include?('-L' + File.join(dir, 'vendor'))
  CextRecord.validate_flags(recipe.fetch('cflags'))
  File.write(makefile, File.read(makefile).sub('-Wall', '-include custom.h'))
  begin
    CextExtconf.recipe(makefile)
    raise 'unsupported preinclude accepted'
  rescue CextExtconf::Refusal => error
    raise unless error.message.include?('explicit [cext.*]')
  end
end
Dir.mktmpdir('spinel-extconf-configure-') do |dir|
  root = File.join(dir, 'package')
  ext = File.join(root, 'ext/sample')
  FileUtils.mkdir_p(ext)
  File.write(File.join(ext, 'sample.c'), 'void Init_sample(void) {}')
  File.write(File.join(ext, 'extconf.rb'), "require 'mkmf'\n$defs << '-DEXAMPLE=7'\ncreate_makefile('nested/sample')\n")
  cache = File.join(dir, 'cache')
  first = CextExtconf.configure(root, cache: cache, cc: 'cc')
  raise 'configuration did not discover extension' unless first.length == 1
  raise 'configuration wrote into package' if File.exist?(File.join(ext, 'Makefile'))
  makefile = Dir.glob(File.join(cache, 'extconf-*/ext/sample/Makefile')).fetch(0)
  timestamp = File.mtime(makefile)
  second = CextExtconf.configure(root, cache: cache, cc: 'cc')
  raise 'configuration cache missed' unless first == second && File.mtime(makefile) == timestamp
  CextRecord.validate_flags(first.fetch(0).fetch('cflags'))
  File.delete(makefile)
  repaired = CextExtconf.configure(root, cache: cache, cc: 'cc')
  raise 'incomplete configuration cache was reused' unless File.file?(makefile) && repaired == first
  cached_source = first.fetch(0).fetch('sources').fetch(0)
  File.delete(cached_source)
  repaired = CextExtconf.configure(root, cache: cache, cc: 'cc')
  raise 'missing configured source was reused' unless File.file?(cached_source) && repaired == first
  previous = ENV['SPIN_CEXT_RUBY']
  begin
    ENV['SPIN_CEXT_RUBY'] = File.join(dir, 'missing-ruby')
    begin
      CextExtconf.configure(root, cache: cache, cc: 'cc')
      raise 'missing host CRuby accepted'
    rescue CextExtconf::Refusal => error
      raise unless error.message.include?('[cext.*]') && error.message.include?('host CRuby')
    end
  ensure
    previous ? ENV['SPIN_CEXT_RUBY'] = previous : ENV.delete('SPIN_CEXT_RUBY')
  end
end
puts 'extconf Makefile flags: OK'
