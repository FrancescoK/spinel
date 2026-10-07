# ThreadGroup, spliced by the parser when a program names `ThreadGroup` and
# defines none of its own: a group lists the threads added to it while they
# are alive, and a thread added to one group leaves the group it was in.
# Every thread not added elsewhere is in ThreadGroup::Default. webrick's
# GenericServer#start gathers its request threads in one and joins them on
# shutdown. Thread#group and enclosing (#enclose answers nothing here; a
# group is never enclosed) are absent.
class ThreadGroup
  @groups = []

  def self.__groups = @groups

  def initialize
    @threads = []
    ThreadGroup.__groups << self
  end

  def add(thread)
    ThreadGroup.__groups.each { |g| g.__remove(thread) }
    @threads << thread unless equal?(Default)
    self
  end

  def list
    if equal?(Default)
      Thread.list.reject { |t| ThreadGroup.__groups.any? { |g| g.__member?(t) } }
    else
      @threads.select(&:alive?)
    end
  end

  def enclosed? = false

  def __remove(thread)
    @threads.reject! { |t| t.equal?(thread) }
  end

  def __member?(thread) = @threads.any? { |t| t.equal?(thread) }

  Default = new
end
