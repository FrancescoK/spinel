# A boxed receiver's dispatch narrows to the classes cls_fact proves it can
# hold (#8530) -- but a shared PRIVATE helper's own parameter can get its
# real class silently dropped from that fact, rather than simply failing to
# narrow it, when a SIBLING caller is reached only through an unresolved
# receiver (a pooled value popped off a Thread::Queue) and is never actually
# invoked at runtime. The two callers' arguments to the shared helper get
# unioned into one fact; the unresolved sibling's "the argument may go
# anywhere" widening then poisons the other, concretely-typed caller's
# argument too, since that widening is irreversible. Before #8530 this
# miscomputed fact was harmless (dispatch still switched on the runtime
# class regardless); after it, the fact's own zero real classes reads as
# "this value holds none of your classes", and the dispatch raises
# NoMethodError instead of running the only real candidate (kilau, found
# 2026-10-12 against Sqlite::Binds#kind; this is the self-contained
# translation, not the original FFI-backed repro).
class Tag
  def initialize(label) = @label = label
  def kind(i) = @label
end

class Worker
  def exec_script(sql) = nil
  def execute(sql, binds)
    prepare(sql, binds)
  end
  def query(sql, binds)
    row = prepare(sql, binds)
    yield row
    nil
  end

  private

  def prepare(sql, binds)
    i = 0
    rc = -1
    while i < 1
      rc = bind(sql, i, binds, i)
      i += 1
    end
    rc
  end

  def bind(stmt, index, binds, i)
    case binds.kind(i)
    when "int" then 1
    else 0
    end
  end
end

class MiniPool
  def initialize
    @idle = Thread::Queue.new
    @idle << Worker.new
  end
  def with
    w = @idle.pop
    begin
      yield w
    ensure
      @idle << w
    end
  end
  def exec_script(sql) = with { |w| w.exec_script(sql) }
  def execute(sql, binds) = with { |w| w.execute(sql, binds) }
  # Never called at runtime; its mere presence, reachable, is what widens
  # Worker#prepare/#bind's shared "binds" parameter.
  def query_all(sql, zzz)
    out = []
    with { |w| w.query(sql, zzz) { |row| out << yield(row) } }
    out
  end
end

pool = MiniPool.new
pool.exec_script("ignored")
p pool.execute("ignored", Tag.new("a"))
puts "done"
