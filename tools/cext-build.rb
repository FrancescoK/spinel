#!/usr/bin/env ruby
require 'digest'
require 'fileutils'
require 'pathname'
require_relative 'spin/toml'
require_relative 'cext-record'
require_relative 'cext-extconf'

module CextBuild
  class Refusal < StandardError; end
  module_function

  def recipes(root)
    path = File.join(root, 'spin.toml')
    doc = File.file?(path) ? TomlDoc.parse(File.read(path)) : TomlDoc.new
    doc.tables('cext').map do |table|
      name = table.delete_prefix('cext.')
      raise Refusal, "#{table}: invalid extension name" unless name.match?(/\A[A-Za-z_][A-Za-z_0-9]*\z/)
      init = doc.get(table, 'init')
      raise Refusal, "#{table}: init must name an Init_ function" unless init.match?(/\AInit_[A-Za-z_0-9]+\z/)
      patterns = doc.array_text(doc.get(table, 'sources')).split("\n")
      raise Refusal, "#{table}: sources must name C source files" if patterns.empty?
      sources = patterns.flat_map do |pattern|
        matches = Dir.glob(File.expand_path(pattern, root)).sort
        raise Refusal, "#{table}: sources entry #{pattern.inspect} matched no C source" if matches.empty? || matches.any? { |p| !File.file?(p) || File.extname(p) != '.c' }
        matches
      end.uniq
      flags = doc.array_text(doc.get(table, 'cflags')).split("\n").map do |flag|
        flag.start_with?('-I') ? '-I' + File.expand_path(flag[2..], root) : flag
      end
      libs = doc.array_text(doc.get(table, 'libs')).split("\n").map do |lib|
        if lib.include?('${build.out}')
          output=ENV.fetch('SPIN_CEXT_BUILD_OUT','')
          raise Refusal,"#{table}: native build output is missing" if output.empty?
          lib=lib.gsub('${build.out}',output)
        end
        lib.start_with?('-') || !lib.include?('/') ? lib : File.expand_path(lib,root)
      end
      link_flags=[]
      libs.each do |lib|
        if lib.start_with?('-') || File.file?(lib)
          link_flags << lib
        else
          begin
            cflags,_,status=Open3.capture3('pkg-config','--cflags',lib)
            ldflags,_,linked=Open3.capture3('pkg-config','--libs',lib)
            if status.success? && linked.success?
              flags.concat(Shellwords.split(cflags));link_flags.concat(Shellwords.split(ldflags))
            else
              link_flags << '-l'+lib
            end
          rescue Errno::ENOENT
            link_flags << '-l'+lib
          end
        end
      end
      libs=link_flags
      init_imports = doc.array_text(doc.get(table, 'init_imports')).split("\n")
      feature = doc.get(table, 'require')
      feature = name if feature.empty?
      raise Refusal, "#{table}: require must be a relative feature path" if feature.start_with?('/') || feature.split('/').any? { |p| p.empty? || p == '.' || p == '..' } || feature.include?("\n")
      {'name' => name, 'init' => init, 'sources' => sources, 'cflags' => flags, 'libs' => libs, 'require' => feature, 'init_imports' => init_imports}
    end
  end

  def fingerprint(recipe, cc)
    compiler = Shellwords.split(cc)
    raise Refusal, 'empty C compiler command' if compiler.empty?
    flags = recipe.fetch('cflags')
    CextRecord.validate_flags(flags)
    inputs = recipe.fetch('sources').dup
    [[], ['-DSP_THREADS']].each do |variant|
      recipe.fetch('sources').each do |source|
        deps = CextRecord.command(*compiler, '-std=c11', '-DSP_CEXT_RECORDER', "-I#{CextRecord::ROOT}/include", *flags, *variant, '-M', '-MT', 'spinel_cext', source)
        inputs.concat(Shellwords.split(deps.partition(':').last.gsub(/\\\n/, ' ')))
      end
    end
    inputs.concat(Dir[File.join(CextRecord::ROOT, 'tools/cext/*')].select { |p| File.file?(p) })
    inputs.concat(%w[cext-build.rb cext-record.rb cext-extconf.rb].map { |name| File.join(CextRecord::ROOT, 'tools', name) })
    inputs.concat(recipe.fetch('libs').select { |p| File.file?(p) })
    bytes = JSON.generate(recipe).b
    bytes << JSON.generate(compiler).b
    bytes << CextRecord.command(*compiler, '--version').b
    inputs.uniq.sort.each do |path|
      bytes << path.b << "\0".b << File.binread(path) << "\0".b
    end
    Digest::SHA256.hexdigest(bytes)
  end

  def build(recipe, cache:, cc: ENV.fetch('CC', 'cc'))
    raise Refusal, 'invalid extension name' unless recipe.fetch('name').match?(/\A[A-Za-z_][A-Za-z_0-9]*\z/)
    key = fingerprint(recipe, cc)
    FileUtils.mkdir_p(cache)
    target = File.join(cache, recipe.fetch('name') + '-' + key)
    File.open(target + '.lock', 'w') do |lock|
      lock.flock(File::LOCK_EX)
      artifacts = %w[complete extension.a extension_mt.a manifest.json manifest_mt.json]
      artifacts << File.join('load', recipe.fetch('require') + '.rb')
      complete = artifacts.all? { |name| File.file?(File.join(target, name)) }
      complete &&= File.read(File.join(target, 'complete')).strip == key
      unless complete
        scratch = Dir.mktmpdir('cext-', cache)
        begin
          plain = nil
          [false, true].each do |threaded|
            suffix = threaded ? '_mt' : ''
            manifest = CextRecord.record(name: recipe.fetch('name'), init: recipe.fetch('init'),
              sources: recipe.fetch('sources'), cflags: recipe.fetch('cflags'), cc: cc, threaded: threaded,
              libs: recipe.fetch('libs'),
              init_imports: recipe.fetch('init_imports', []),
              output: File.join(scratch, "manifest#{suffix}.json"),
              declarations: File.join(scratch, "declarations#{suffix}.rb"),
              object_archive: File.join(scratch, "extension#{suffix}.a"))
            if plain && manifest.fetch('definitions') != plain.fetch('definitions')
              raise Refusal, "#{recipe['name']}: threaded and plain extension declarations differ"
            end
            if plain
              %w[literal_ids funcall_arities ivars evals].each do |field|
                plain[field] = (plain.fetch(field) + manifest.fetch(field)).uniq.sort
              end
              plain['constant_reads'] ||= manifest['constant_reads']
              plain['spread_sends'] = true if manifest['spread_sends']
            else
              plain = manifest
            end
          end
          File.write(File.join(scratch, 'manifest.json'), JSON.pretty_generate(plain) + "\n")
          File.write(File.join(scratch, 'declarations.rb'), CextRecord.render(plain))
          loader = File.join(scratch, 'load', recipe.fetch('require') + '.rb')
          FileUtils.mkdir_p(File.dirname(loader))
          FileUtils.cp(File.join(scratch, 'declarations.rb'), loader)
          File.write(File.join(scratch, 'complete'), key + "\n")
          FileUtils.rm_rf(target) if File.exist?(target)
          File.rename(scratch, target)
        ensure
          FileUtils.rm_rf(scratch) if File.exist?(scratch)
        end
      end
    end
    {'directory' => target, 'include' => File.join(target, 'load'),
     'archive' => File.join(target, 'extension.a'), 'libs' => recipe.fetch('libs')}
  rescue CextRecord::Refusal => error
    raise Refusal, error.message
  end
end

module CextBuild
  # A bundled package's extension (make: packages/<pkg>/build/cext): the
  # archives go to OUT/<name>.a and OUT/<name>_mt.a, and the declarations
  # beside the package's Ruby as <root>/<require>.rb, where the compiler's
  # package tier finds them, with a `__cext_link` naming the archive
  # (relative to the declaration file) and the libraries to link.
  def self.bundle(root, out, results)
    FileUtils.mkdir_p(out)
    results.each do |result|
      recipe = result.fetch('recipe')
      name = recipe.fetch('name')
      FileUtils.cp(File.join(result.fetch('directory'), 'extension.a'), File.join(out, name + '.a'))
      FileUtils.cp(File.join(result.fetch('directory'), 'extension_mt.a'), File.join(out, name + '_mt.a'))
      loader = File.join(root, recipe.fetch('require') + '.rb')
      FileUtils.mkdir_p(File.dirname(loader))
      archive = Pathname.new(File.join(out, name + '.a')).relative_path_from(Pathname.new(File.dirname(loader))).to_s
      libs = recipe.fetch('libs').select { |l| l.start_with?('-l') }.map { |l| l.delete_prefix('-l') }.join(';')
      text = File.read(File.join(result.fetch('include'), recipe.fetch('require') + '.rb'))
      text << "__cext_link(#{archive.dump}, #{libs.dump})\n"
      File.write(loader, text)
    end
    File.write(File.join(out, 'complete'), results.map { |r| r.fetch('directory') }.join("\n") + "\n")
  end

  def self.main(args)
    flags_only = args.first == '--flags'
    bundle_out = args.first == '--bundle'
    args.shift if flags_only || bundle_out
    root = args.shift or raise Refusal, 'usage: spinel-cext-build ROOT CACHE [CC]'
    cache = args.shift or raise Refusal, 'usage: spinel-cext-build ROOT CACHE [CC]'
    cc = args.shift || ENV.fetch('CC', 'cc')
    raise Refusal, 'unexpected builder arguments' unless args.empty?
    root = File.expand_path(root)
    cache = File.expand_path(cache)
    if bundle_out
      out = cache
      cache = File.join(out, 'cache')
    end
    configured = recipes(root)
    configured = CextExtconf.configure(root, cache: cache, cc: cc) if configured.empty?
    results = configured.map { |recipe| build(recipe, cache: cache, cc: cc).merge('recipe' => recipe) }
    if bundle_out
      bundle(root, out, results)
    elsif flags_only
      results.each do |result|
        puts "include\t#{result.fetch('include')}"
        puts "link\t#{result.fetch('archive')}"
        result.fetch('libs').each do |lib|
          input = lib.start_with?('-') || File.file?(lib) ? lib : '-l' + lib
          puts "link\t#{input}"
        end
      end
    else
      puts JSON.generate(results)
    end
    0
  rescue Refusal, CextExtconf::Refusal, SystemCallError => error
    warn "spin cext: #{error.message}"
    2
  end
end
exit CextBuild.main(ARGV) if $PROGRAM_NAME == __FILE__
