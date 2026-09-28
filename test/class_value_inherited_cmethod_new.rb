# An inherited class method whose body calls bare `new`, reached through a
# Class value, constructs the class the value holds, not the defining one.

class Writer
  KIND = "base"
  def self.open(path, rate:)
    writer = new(path, rate:)
    yield writer
    writer.finish
  end
  def self.make(path) = new(path, rate: 1)
  def self.built(path) = self.new(path, rate: 5)
  def self.kind_len(path) = new(path, rate: 0).kind.length
  def self.label = "#{name}/#{self::KIND}"
  def initialize(path, rate:) = (@path = path; @rate = rate; @out = [])
  def finish = "#{kind} #{@path} #{@rate} #{@out.length}"
  def kind = "writer"
end

class WAV < Writer
  KIND = "w"
  def kind = "wav"
end

class Wav64 < WAV
  KIND = "w64"
  def kind = "wav64"
end

class AIFF < Writer
  KIND = "a"
  def self.make(path) = "own #{path}"
  def kind = "aiff"
end

CONTAINERS = { ".wav" => WAV, ".w64" => Wav64, ".aiff" => AIFF }.freeze
%w[.wav .w64 .aiff].each do |ext|
  container = CONTAINERS.fetch(ext)
  puts container.open("out", rate: 44_100) { |writer| p writer.class }
  made = container.make("m")
  puts made.is_a?(Writer) ? made.finish : made
  p container.built("b").class
  puts container.label
end

[Writer, WAV].each { |k| puts k.make("k").finish }

pick = ARGV.empty? ? Wav64 : WAV
p pick.make("z").class
puts WAV.open("d", rate: 2) { |w| p w.class }
p AIFF.built("d").class
p WAV.kind_len("x")
p CONTAINERS.fetch(".w64").kind_len("x")
