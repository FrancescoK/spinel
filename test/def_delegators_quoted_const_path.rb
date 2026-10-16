# def_delegators / def_delegator whose receiver is a quoted Symbol naming a
# constant or a constant path (faraday's NestedParamsEncoder writes
# `def_delegators :'Faraday::Utils', :escape, :unescape` in `class << self`).

require "forwardable"

module Faraday
  module Utils
    def self.escape(s) = "e:#{s}"
    def self.unescape(s) = "u:#{s}"
  end
end

module Enc
  class << self
    extend Forwardable
    def_delegators :'Faraday::Utils', :escape, :unescape
  end
end

module Plain
  def self.hi(x) = "hi #{x}"
end

class W
  extend Forwardable
  def_delegators :"Plain", :hi
  def_delegator :"Faraday::Utils", :escape, :esc
end

p Enc.escape("a"), Enc.unescape("b")
p W.new.hi(1), W.new.esc(2)
