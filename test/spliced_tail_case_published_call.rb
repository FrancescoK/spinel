# A yielding method spliced in with its block answers its tail into the
# call's result slot: a `case` takes each arm, and a call whose method
# publishes its String (a constant, a frozen literal) hands that String on.
# An argument the value is passed as is that String itself.

AUTO = %(load"*",8\rrun\r)

module Vic
  AUTO = %(lO"*",8,1\rrun\r)
  def self.autostart(data) = data && data.length > 2 ? %(lO"*",8\rrun\r) : AUTO
end

module Cbm
  AUTO = %(load"*",8\rrun\r)
end

class Machine
  attr_reader :family, :typed

  def initialize(family)
    @family = family
    @typed = []
  end

  def type_text(text) = @typed << text
end

def autostart(machine)
  case machine.family
  when :vic20 then Vic.autostart(yield)
  when :cbm2 then Cbm::AUTO
  else AUTO
  end
end

def attach(machine, data)
  machine.type_text(autostart(machine) { data })
end

def plain(machine)
  yield
  Vic.autostart(machine.family.to_s)
end

machines = [Machine.new(:vic20), Machine.new(:vic20), Machine.new(:cbm2), Machine.new(:c64)]
attach(machines[0], "abc")
attach(machines[1], nil)
attach(machines[2], "abc")
attach(machines[3], "abc")
machines[3].type_text(plain(machines[3]) { 1 })
s = +"typed"
machines[0].type_text(s)
s << "!"
p machines.map(&:typed)
p machines[1].typed[0].equal?(Vic::AUTO), machines[2].typed[0].equal?(Cbm::AUTO),
  machines[3].typed[0].equal?(AUTO), machines[0].typed[1].equal?(s), machines[3].typed[1].frozen?
