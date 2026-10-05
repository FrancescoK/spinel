# A subclass of Array is a real Array (#7449): ONCE Campfire pages its
# messages with `class Page < Array`, whose initialize hands the records to
# Array's through super and keeps its relation beside them. Array's methods
# dispatch on the page and answer plain Arrays where CRuby's do, it is an
# Array to is_a?, == (both ways), p, flatten and a splat, and it flows into
# code written for Arrays (the relation's `without(page)`).
class Page < Array
  def initialize(records, source)
    super(records)
    @source = source
  end

  def loaded? = true

  def source = @source
end

def flatten_ids(*lists) = lists.flatten.sum

page = Page.new([3, 1, 2], "room 1")
p page.first(2)
p page.map { |n| n * 10 }
p page.is_a?(Array)
p page == [3, 1, 2]
p [3, 1, 2] == page
p page.source
p page.loaded?
p flatten_ids(page, [4])
p page

class Message
  attr_reader :id, :body

  def initialize(id, body)
    @id = id
    @body = body
  end

  def inspect = "#<Message #{id}>"
end

class Relation
  def initialize(records) = @records = records
  def last(n) = @records.last(n)
  def without(records) = Relation.new(@records - records)
  def ids = @records.map(&:id)
  def preload_associations(records) = records.size
end

module Pagination
  class Page < Array
    def self.load(relation, direction, size)
      new(relation.public_send(direction, size), relation)
    end

    def initialize(records, relation)
      super(records)
      @relation = relation
    end

    def loaded? = true

    def preload_associations(records)
      @relation.preload_associations(records)
    end
  end
end

rel = Relation.new((1..5).map { |i| Message.new(i, "m#{i}") })
messages = Pagination::Page.load(rel, :last, 2)
p messages, messages.class, messages.loaded?
p messages.map(&:id), messages.first.body, messages.first(1).class
p messages.preload_associations(messages)
p rel.without(messages).ids
messages.each { |m| puts m.body }
p messages.kind_of?(Array), messages.instance_of?(Array)
p messages.min_by(&:id), messages.sum(&:id)
