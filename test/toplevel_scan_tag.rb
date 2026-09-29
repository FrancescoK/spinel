# The allocation-report tag table names a scan function per class that gets
# one; the Toplevel pseudo-class (created here by the class object stored
# through a defaulted `base = Object`) never has one, and naming it was an
# undeclared identifier in C. A Hash reopen alongside is what made the
# pseudo-class count as instantiated.
class Hash
  def slice!(*keys)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    hash.default      = default
    hash.default_proc = default_proc if default_proc
    replace(hash)
    omit
  end
  def extract!(*keys)
    keys.each_with_object(self.class.new) { |key, result| result[key] = delete(key) if has_key?(key) }
  end
end
module Hooks
  def self.extended(base)
    base.class_eval do
      @load_hooks = Hash.new { |h, k| h[k] = [] }
      @loaded     = Hash.new { |h, k| h[k] = [] }
    end
  end
  def on_load(name, &block)
    @loaded[name].each { |base| block.call(base) }
    @load_hooks[name] << block
  end
  def run_load_hooks(name, base = Object)
    @loaded[name] << base
    @load_hooks[name].each { |hook| hook.call(base) }
  end
end
module App
  extend Hooks
end
App.run_load_hooks(:i18n)
App.on_load(:i18n) { |b| puts "late hook sees #{b}" }
# The Hash methods stay uncalled: the reopen's mere presence is what mattered.
puts "ok"
