# A class method called with keyword arguments on a Class value, when an
# unrelated class defines an instance method of the same name, runs the
# class method with its keywords bound by name.

class WAV
  def self.open(path, rate:, bits: 16) = yield("wav #{path} #{rate} #{bits}")
  def self.probe(path, rate:) = "wav-probe #{path} #{rate}"
end

class AIFF
  def self.open(path, rate:, bits: 24)
    yield "aiff #{path} #{rate} #{bits}"
  end
  def self.probe(path, rate:) = "aiff-probe #{path} #{rate}"
end

class Drive
  def open(name, mode:) = "drive #{name} #{mode}"
  def probe(name, rate:) = "drive-probe #{name} #{rate}"
end

CONTAINERS = { ".wav" => WAV, ".aiff" => AIFF }.freeze

%w[.wav .aiff].each do |ext|
  container = CONTAINERS.fetch(ext)
  container.open("out", rate: 44_100) { |w| puts w }
  puts container.open("o2", bits: 8, rate: 1) { |w| w.upcase }
  puts container.probe("p", rate: 2)
end

puts Drive.new.open("x", mode: 1)
puts Drive.new.probe("y", rate: 3)
