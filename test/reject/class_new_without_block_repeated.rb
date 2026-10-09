# A no-block class factory must not become one reused static class.
# spinel: reject-subclass: Class.new(parent)
class NoBlockRepeatedBase; end
def no_block_factory = Class.new(NoBlockRepeatedBase)
p no_block_factory == no_block_factory
