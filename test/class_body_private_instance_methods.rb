# private_instance_methods(false) and protected_instance_methods(false)
# called bare in a class body answer the class's own methods of that
# visibility, as instance_methods(false) does (actionpack's
# Journey::Visitors build their DISPATCH_CACHE from the private visit_*s).
class Visitor
  DISPATCH = {}
  def accept(n) = send(DISPATCH[n])
  def pub = :pub
  protected
  def guard = :guard
  private
  def visit_LITERAL = :literal
  def visit_DOT = :dot
  def helper = :helper

  private_instance_methods(false).each do |pim|
    next unless pim =~ /^visit_(.*)$/
    DISPATCH[$1.to_sym] = pim
  end
  p private_instance_methods(false).sort
  p protected_instance_methods(false)
  p public_instance_methods(false).sort
end
p Visitor::DISPATCH.sort
p Visitor.new.accept(:DOT)
