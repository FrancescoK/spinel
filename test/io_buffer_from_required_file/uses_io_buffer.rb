# IO::Buffer named only here, never in the entry file.
READER = -> { IO::Buffer.new(8) }

def self.make_buf
  IO::Buffer.new(8)
end
