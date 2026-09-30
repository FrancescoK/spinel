module DriveRow
  DRIVE_DIR = /drive(\d)?/

  def drive? = !disk.nil? || dir.match?(DRIVE_DIR)

  def drive_kind
    return if cartridge || !drive?
    dir.match(DRIVE_DIR)&.[](1) ? :testsuite : :drive
  end
end

module Named
  def label = "#{prg}@#{dir}"
end

module Finder
  def find(prg) = "found #{prg}"
end

module Loud
  def label = "#{super}!"
end

TestCase = Struct.new(:dir, :prg, :type, :timeout, :options, :cartridge, :occurrence, :disk) do
  include DriveRow
  include Named
  extend Finder
  prepend Loud

  def slow? = timeout > 10
end

cases = [
  TestCase.new("drive1/a", "a.prg", :basic, 5, {}, nil, 1, nil),
  TestCase.new("plain/b", "b.prg", :basic, 20, {}, nil, 2, "b.d64"),
  TestCase.new("drive/c", "c.prg", :cart, 5, {}, "c.crt", 1, nil),
  TestCase.new("plain/d", "d.prg", :basic, 5, {}, nil, 1, nil)
]
cases.each do |tc|
  p [tc.label, tc.drive?, tc.drive_kind, tc.slow?]
end
p TestCase.find("x.prg")

Point = Data.define(:x, :y) do
  include Named

  def prg = x
  def dir = y
end
p Point.new(x: 1, y: 2).label
