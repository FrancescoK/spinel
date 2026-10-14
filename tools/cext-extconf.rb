# Read mkmf's flags; the host CRuby configures, Spinel compiles the extension.
require 'fileutils'
require 'digest'
require 'open3'
require 'shellwords'
require 'tmpdir'
require 'json'

module CextExtconf
  class Refusal < StandardError; end
  module_function

  def configure(root, cache:, cc:)
    scripts = Dir.glob(File.join(root, 'ext/**/extconf.rb')).sort
    return [] if scripts.empty?
    ruby = ENV.fetch('SPIN_CEXT_RUBY', 'ruby')
    out, err, status = Open3.capture3(ruby, '-e', 'abort unless RUBY_ENGINE == "ruby"; print RUBY_DESCRIPTION')
    raise Refusal, 'C extension needs [cext.*] in spin.toml or a host CRuby (SPIN_CEXT_RUBY)' unless status.success?
    files = Dir.glob(File.join(root, '**/*'), File::FNM_DOTMATCH).select do |path|
      relative = path.delete_prefix(root + '/')
      File.file?(path) && !relative.split('/').any? { |part| %w[.git build .spin].include?(part) } && !path.start_with?(File.expand_path(cache) + '/')
    end.sort
    bytes = out.b + cc.b
    files.each { |path| bytes << path.delete_prefix(root).b << "\0" << File.binread(path) << "\0" }
    key = Digest::SHA256.hexdigest(bytes)
    FileUtils.mkdir_p(cache)
    target = File.join(cache, 'extconf-' + key)
    File.open(target + '.lock', 'w') do |lock|
      lock.flock(File::LOCK_EX)
      makefiles = scripts.map { |script| File.join(target, File.dirname(script.delete_prefix(root + '/')), 'Makefile') }
      complete = File.file?(File.join(target, 'complete')) && makefiles.all? { |path| File.file?(path) }
      complete &&= File.read(File.join(target, 'complete')) == key
      if complete
        begin
          artifacts = JSON.parse(File.read(File.join(target, 'artifacts.json')))
          complete = artifacts.is_a?(Array) && artifacts.all? { |path| File.file?(File.join(target, path)) }
        rescue StandardError
          complete = false
        end
      end
      unless complete
        scratch = Dir.mktmpdir('extconf-', cache)
        begin
          files.each do |path|
            destination = File.join(scratch, path.delete_prefix(root + '/'))
            FileUtils.mkdir_p(File.dirname(destination))
            FileUtils.cp(path, destination)
          end
          scripts.each do |script|
            copied = File.join(scratch, script.delete_prefix(root + '/'))
            output, errors, configured = Open3.capture3({'CC' => cc}, ruby, File.basename(copied), '--use-system-libraries', chdir: File.dirname(copied))
            raise Refusal, "extconf failed: #{output}#{errors}; provide [cext.*] in spin.toml" unless configured.success?
            recipe(File.join(File.dirname(copied), 'Makefile'))
          end
          # mkmf and extconf can embed absolute paths to generated vendor
          # archives. Preserve those references when publishing the cache.
          Dir.glob(File.join(scratch, '**/Makefile')).each do |makefile|
            File.write(makefile, File.read(makefile).gsub(scratch, target))
          end
          artifacts = Dir.glob(File.join(scratch, '**/*'), File::FNM_DOTMATCH)
            .select { |path| File.file?(path) }.map { |path| path.delete_prefix(scratch + '/') }.sort
          File.write(File.join(scratch, 'artifacts.json'), JSON.generate(artifacts))
          File.write(File.join(scratch, 'complete'), key)
          FileUtils.rm_rf(target) if File.exist?(target)
          File.rename(scratch, target)
        ensure
          FileUtils.rm_rf(scratch) if File.exist?(scratch)
        end
      end
    end
    scripts.map { |script| recipe(File.join(target, File.dirname(script.delete_prefix(root + '/')), 'Makefile')) }
  rescue Errno::ENOENT => error
    raise Refusal, "C extension needs [cext.*] in spin.toml or a host CRuby: #{error.message}"
  end

  def variables(path)
    values = {}
    File.read(path).gsub(/\\\n/, ' ').each_line do |line|
      match = line.match(/\A\s*([A-Za-z_][A-Za-z_0-9]*)\s*(\+=|:=|\?=|=)\s*(.*?)\s*\z/)
      next unless match
      key, operation, value = match.captures
      if operation == '+='
        values[key] = values.fetch(key, '') + ' ' + value
      elsif operation != '?=' || !values.key?(key)
        values[key] = value
      end
    end
    values
  end

  def expand(value, values)
    30.times do
      changed = value.gsub(/\$\(([A-Za-z_][A-Za-z_0-9]*)\)|\$\{([A-Za-z_][A-Za-z_0-9]*)\}/) { values.fetch($1 || $2, '') }
      return changed unless changed.match?(/\$[({]/)
      raise Refusal, 'extconf Makefile contains recursive or computed flags; provide [cext.*] in spin.toml' if changed == value
      value = changed
    end
    raise Refusal, 'extconf Makefile flag expansion exceeds 30 levels'
  end

  def recipe(makefile)
    values = variables(makefile)
    dir = File.dirname(makefile)
    get = ->(key) { expand(values.fetch(key, ''), values) }
    name = get.call('TARGET')
    raise Refusal, 'extconf did not generate a C extension target' unless name.match?(/\A[A-Za-z_][A-Za-z_0-9]*\z/)
    srcdir = File.expand_path(get.call('srcdir'), dir)
    sources = Shellwords.split(get.call('SRCS')).map { |file| File.expand_path(file, srcdir) }
    raise Refusal, 'extconf did not name its C sources' if sources.empty? || sources.any? { |path| !File.file?(path) || File.extname(path) != '.c' }
    ruby_dirs = %w[hdrdir rubyhdrdir arch_hdrdir rubyarchhdrdir].map { |key| File.expand_path(get.call(key), dir) }.uniq
    words = Shellwords.split(%w[INCFLAGS CPPFLAGS CFLAGS].map { |key| get.call(key) }.join(' '))
    flags = []
    index = 0
    while index < words.length
      word = words[index]
      if %w[-I -D -U].include?(word)
        index += 1
        raise Refusal, 'extconf compiler flag has no argument' unless words[index]
        word += words[index]
      end
      if word == '-arch'
        index += 1
        raise Refusal, 'extconf architecture flag has no argument' unless words[index]
      elsif word.start_with?('-I')
        path = File.expand_path(word[2..], dir)
        flags << '-I' + path unless ruby_dirs.any? { |ruby_dir| path == ruby_dir || path.start_with?(ruby_dir + '/') }
      elsif word == '-include'
        index += 1
        # mkmf's stdbool preinclude is redundant with the restricted ruby.h.
        raise Refusal, 'extconf preincluded headers require an explicit [cext.*] recipe' unless words[index] == 'stdbool.h'
      elsif word.start_with?('-D', '-U', '-std=', '-O', '-W', '-g', '-f') || word == '-pipe' || word == '-pthread'
        flags << word
      else
        raise Refusal, "unsupported extconf compiler flag #{word.inspect}; provide [cext.*] in spin.toml"
      end
      index += 1
    end
    link_words = Shellwords.split(%w[LOCAL_LIBS LIBS DLDFLAGS].map { |key| get.call(key) }.join(' '))
    libs = []
    index = 0
    while index < link_words.length
      word = link_words[index]
      if word == '-L' || word == '-l'
        index += 1
        raise Refusal, 'extconf library flag has no argument' unless link_words[index]
        word += link_words[index]
      end
      libs << word if word.start_with?('-l', '-L') || word.end_with?('.a', '.so', '.dylib')
      index += 1
    end
    libs = libs.map { |word| word.start_with?('-L') ? '-L' + File.expand_path(word[2..], dir) : word.start_with?('-l') ? word : File.expand_path(word, dir) }
    prefix = get.call('target_prefix').sub(/\A\//, '')
    feature = prefix.empty? ? name : prefix + '/' + name
    {'name' => name, 'init' => 'Init_' + name, 'sources' => sources, 'cflags' => flags.uniq, 'libs' => libs.uniq, 'require' => feature}
  end
end
