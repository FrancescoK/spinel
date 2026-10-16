# The parent of a compact path (`class A::B`) is looked up as Ruby looks
# up a constant: the lexical scopes, then the ancestors of the innermost
# class, then the top level. A parent found in a superclass or an included
# module is that class, not a top-level class with the same name.

class Invoice
  class Line
    def source = "top invoice line"
  end
end

class Document
  class Invoice
  end
end

class Receipt < Document
  class Invoice::Line
    def source = "document invoice line"
  end
end

class Settings
  class Loader
    def source = "app settings"
  end
end

module Plugin
  class Settings
  end
end

class Importer
  include Plugin

  class Settings::Loader
    def source = "plugin settings"
  end
end

puts Invoice::Line.new.source
puts Document::Invoice::Line.new.source
puts Document::Invoice::Line.name
puts Settings::Loader.new.source
puts Plugin::Settings::Loader.new.source
puts Plugin::Settings::Loader.name
