# class_eval and its kin given a Method object as the block call the method,
# which keeps its own self: the evals pass the receiver, the execs their
# arguments, and the call answers what the method answers.
module Installer
  def self.install(k) = "#{self} installed into #{k}"
  def self.pair(a, b) = [a, b]
end

class Host
  p class_eval(&Installer.method(:install))
  p self.module_eval(&Installer.method(:install))
  p class_exec(1, 2, &Installer.method(:pair))
end

p Host.class_eval(&Installer.method(:install))
p Host.instance_eval(&Installer.method(:install))
p Host.instance_exec(:a, :b, &Installer.method(:pair))
