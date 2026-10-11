# Spinel bundled `tmpdir` -- a carried-C spin package (Path B).
#
# Dir.tmpdir and Dir.mktmpdir live in this package's C (sp_tmpdir.c,
# linked only when `require "tmpdir"` appears). The block form,
# prefix_suffix handling, and UNUSABLE_CHARS filtering are plain Ruby.
#
# CRuby's tmpdir.rb requires fileutils at load time, so a program that only
# requires tmpdir (or tempfile, which requires tmpdir) can name FileUtils.
# This package does the same, and its block form cleans up through
# FileUtils.remove_entry as CRuby's does.
require "fileutils"

module TmpdirPackage
  native_lib "tmpdir"
  native_obj "packages/tmpdir/sp_tmpdir.o"
  native_func :Dir_tmpdir,     [],         :string, "sp_Dir_tmpdir"
  native_func :Dir_mktmpdir,   [:string],  :string, "sp_Dir_mktmpdir"
  native_func :Dir_mktmpdir_pps, [:string, :string, :string, :int], :string, "sp_Dir_mktmpdir_pps"
end

# Characters CRuby strips from prefix/suffix to keep paths portable.
UNUSABLE_CHARS = "^,-.0-9A-Z_a-z~"

# Plain Ruby surface on top of the C binding. Dir is a class in spinel
# (not a module), so reopen it directly and add the singleton methods.
class Dir
  def self.tmpdir
    TmpdirPackage.Dir_tmpdir
  end

  def self.mktmpdir(prefix_suffix = nil, parent_dir = nil, *rest, **options, &block)
    # Normalize prefix_suffix: nil -> "d", string -> s, array -> [a, b].
    if prefix_suffix.nil?
      prefix = "d"
      suffix = nil
    elsif prefix_suffix.is_a?(Array)
      p0 = prefix_suffix[0]
      prefix = p0.is_a?(String) ? p0 : (String.try_convert(p0) or
        raise ArgumentError, "unexpected prefix: #{p0.inspect}")
      p1 = prefix_suffix[1]
      if p1
        suffix = p1.is_a?(String) ? p1 : (String.try_convert(p1) or
          raise ArgumentError, "unexpected suffix: #{p1.inspect}")
      else
        suffix = nil
      end
    else
      prefix = prefix_suffix.is_a?(String) ? prefix_suffix :
               (String.try_convert(prefix_suffix) or
                raise ArgumentError, "unexpected prefix: #{prefix_suffix.inspect}")
      suffix = nil
    end
    # CRuby: strip unusable characters from prefix and suffix.
    prefix = prefix.delete(UNUSABLE_CHARS)
    suffix = suffix.delete(UNUSABLE_CHARS) if suffix

    # parent_dir: explicit, or Dir.tmpdir. CRuby's Tmpname.create also
    # accepts a positional tmpdir arg, but the public API only documents
    # the 2-arg form.
    parent = parent_dir ? File.path(parent_dir) : Dir.tmpdir
    raise ArgumentError, "empty parent path" if parent.empty?

    # CRuby's max_try bounds the retries on a name collision. It was
    # computed and then dropped, so the option was silently ignored.
    max_try = options[:max_try] || 10000
    raise ArgumentError, "max_try must be positive" if max_try < 1

    path = TmpdirPackage.Dir_mktmpdir_pps(prefix, parent, suffix || "", max_try)

    if block
      begin
        yield path.dup
      ensure
        # CRuby raises ArgumentError if the parent directory is
        # world-writable without the sticky bit: a symlink there could
        # redirect our cleanup to an arbitrary location. Check the
        # parent first, before touching path, so we never delete
        # through a hostile parent. CRuby runs this check only when
        # no parent was given; a parent the caller named is the
        # caller's to vouch for.
        unless parent_dir
          base = File.dirname(path)
          stat = File.stat(base) rescue nil
          if stat && (stat.mode & 0o002) != 0 && (stat.mode & 0o1000) == 0
            # world-writable (o+w) and NOT sticky (no t-bit) -> reject.
            raise ArgumentError, "parent directory is world writable but not sticky: #{base}"
          end
        end
        FileUtils.remove_entry(path) if File.symlink?(path) || File.exist?(path)
      end
    else
      path
    end
  end
end
