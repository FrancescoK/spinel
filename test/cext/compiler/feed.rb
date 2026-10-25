# frozen_string_literal: true
require_relative 'feed'

class FeedQueue
  def initialize(text)
    @q = []
    text.split(",").each { |word| @q.push [word, word.upcase] }
    @q << [1, 2, 3]
    @q.unshift([:first])
    @q[@q.size] = [1.5]
  end

  def next_item = @q.shift
end

p CextFeed.drain(FeedQueue.new("x,y"))
