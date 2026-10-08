# A subclass's ivar layout is rebuilt by inherit_members after the fixpoint,
# and the rebuild kept only the ivar's type: the pin narrow_object_arrays had
# set beside it was dropped, so the final narrowing no longer saw the ivar as
# a slot, the locals in its component fell back to the poly array, and the C
# did not build (#4642: a controller under a superclass storing a fresh
# object array into an ivar and handing it to a declared parameter).
# spinel: rbs-seed-check
class HatRequest
  attr_reader :id
  def initialize(id)
    @id = id
  end
  def self.from_row(row) = new(row)
end

module Views
  module Hats
    def self.requests_index_into(io, hat_requests, notice, alert)
      io << "<div>"
      if hat_requests.length == 0
        io << "none"
      else
        io << hat_requests.length.to_s
      end
      io << "</div>"
      nil
    end

    def self.requests_index(hat_requests, notice = nil, alert = nil)
      io = String.new
      Views::Hats.requests_index_into(io, hat_requests, notice, alert)
      io
    end
  end
end

class ApplicationController
  def initialize
    @flash = {}
    @title = ""
  end
  def render(s) = puts(s)
end

class HatsController < ApplicationController
  def requests_index
    @title = "Hat Requests"
    results = []
    [1, 2, 3].each do |r|
      results << HatRequest.from_row(r)
    end
    @hat_requests = results
    render(Views::Hats.requests_index(@hat_requests, @flash[:notice], @flash[:alert]))
  end
end

HatsController.new.requests_index
