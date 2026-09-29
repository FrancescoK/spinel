# `self` in a class or module body is the class object itself: cgi/escape.rb
# picks a target with `defined?(CGI::EscapeExt) && ... ? CGI::EscapeExt : self`
# in the body of CGI::Escape and reopens it. It read as the main object
# (top-level self), so the target was main.

module Esc
  SELF = self
  p self
  def self.escapeHTML(s) = s.gsub("<", "&lt;")
  target = defined?(Esc::Ext) && Esc::Ext.method_defined?(:escapeHTML) ? Esc::Ext : self
  p target
  p target.escapeHTML("<x>")
  p self == Esc, self.name
end
p Esc::SELF, Esc::SELF == Esc

class Widget
  p self
  KIND = self.name
  def self.make = "made by #{self}"
end
p Widget::KIND, Widget.make
p self
