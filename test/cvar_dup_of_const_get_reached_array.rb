# A constant Array of Strings a runtime-name const_get can reach takes the
# general Array form late, under the String-sharing rule. A class variable a
# class body wrote its copy into (`@@search_path = DEFAULT.dup`, tzinfo's
# shape), an instance variable and a global written the same way must follow
# that widening: each kept the String Array slot the fixpoint gave it, and the
# copy no longer fit it.
class Zoneinfo
  DEFAULT_SEARCH_PATH = ['/usr/share/zoneinfo', '/usr/share/lib/zoneinfo', '/etc/zoneinfo'].freeze
  private_constant :DEFAULT_SEARCH_PATH

  @@search_path = DEFAULT_SEARCH_PATH.dup

  class << self
    def search_path
      @@search_path
    end

    def search_path=(path)
      @@search_path = process_search_path(path, DEFAULT_SEARCH_PATH)
    end

    private

    def process_search_path(path, default)
      if path
        if path.kind_of?(String)
          path.split(File::PATH_SEPARATOR)
        else
          path.collect(&:to_s)
        end
      else
        default.dup
      end
    end
  end

  def initialize
    @dirs = DEFAULT_SEARCH_PATH.dup
  end

  def first_dir
    self.class.search_path.each do |path|
      return path if path.start_with?('/usr')
    end
    nil
  end

  def dirs = @dirs

  # a constant reached by a name computed at run time
  def lookup(identifier)
    m = Object
    identifier.split('::').each { |part| m = m.const_get(part) }
    m
  end
end

$paths = Zoneinfo.send(:const_get, :DEFAULT_SEARCH_PATH).dup

p Zoneinfo.search_path
p Zoneinfo.new.first_dir
p Zoneinfo.new.dirs
p $paths
p Zoneinfo.new.lookup('Zoneinfo')

Zoneinfo.search_path = '/a:/b'
p Zoneinfo.search_path
Zoneinfo.search_path = [:x, 'y']
p Zoneinfo.search_path
Zoneinfo.search_path = nil
p Zoneinfo.search_path
p Zoneinfo.search_path.frozen?
