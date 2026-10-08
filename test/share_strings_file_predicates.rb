# spinel: share
# spinel: gc-minor
# File and FileTest path tests leave mutable and frozen String paths alone.
# Numeric and nil answers are values, not aliases of either path argument.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_file_predicates_#{Process.pid}.txt")
File.write(path, "abc")
File.chmod(0o644, path)
original = path.dup
frozen_path = path.dup.freeze
p File.blockdev?(path) == FileTest.blockdev?(frozen_path)
p File.chardev?(path) == FileTest.chardev?(frozen_path)
p File.directory?(path) == FileTest.directory?(frozen_path)
p File.empty?(path) == FileTest.empty?(frozen_path)
p File.executable?(path) == FileTest.executable?(frozen_path)
p File.executable_real?(path) == FileTest.executable_real?(frozen_path)
p File.exist?(path) == FileTest.exist?(frozen_path)
p File.file?(path) == FileTest.file?(frozen_path)
p File.grpowned?(path) == FileTest.grpowned?(frozen_path)
p File.identical?(path, frozen_path) == FileTest.identical?(frozen_path, path)
p File.owned?(path) == FileTest.owned?(frozen_path)
p File.pipe?(path) == FileTest.pipe?(frozen_path)
p File.readable?(path) == FileTest.readable?(frozen_path)
p File.readable_real?(path) == FileTest.readable_real?(frozen_path)
p File.setgid?(path) == FileTest.setgid?(frozen_path)
p File.setuid?(path) == FileTest.setuid?(frozen_path)
p File.size(path) == FileTest.size(frozen_path)
p File.size?(path) == FileTest.size?(frozen_path)
p File.socket?(path) == FileTest.socket?(frozen_path)
p File.sticky?(path) == FileTest.sticky?(frozen_path)
p File.symlink?(path) == FileTest.symlink?(frozen_path)
p File.world_readable?(path) == FileTest.world_readable?(frozen_path)
p File.world_writable?(path) == FileTest.world_writable?(frozen_path)
p File.writable?(path) == FileTest.writable?(frozen_path)
p File.writable_real?(path) == FileTest.writable_real?(frozen_path)
p File.zero?(path) == FileTest.zero?(frozen_path)
p File.size?(path)
p FileTest.size?(frozen_path)
p File.world_readable?(path)
p FileTest.world_readable?(frozen_path)
p File.world_writable?(path)
p FileTest.world_writable?(frozen_path)
p path == original
path << ".missing"
p File.exist?(path)
p FileTest.readable?(path)
p File.size?(path)
p FileTest.size?(path)
p File.zero?(path)
p FileTest.empty?(path)
File.write(original, "")
p File.size?(original)
p FileTest.size?(original)
p File.zero?(original)
p FileTest.empty?(original)
File.delete(original)
mutator = ->(value) { value << "!" }
text = +"live"
mutator.call(text)
p text
