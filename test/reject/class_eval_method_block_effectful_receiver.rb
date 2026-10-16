# spinel: reject-subclass: (CallNode `class_eval`)
# `make_target.class_eval(&make_installer.method(:install))` evaluates
# make_target first, then make_installer. Called as make_installer.install
# (make_target) the order would turn around, so the call is refused rather
# than lowered when either receiver has an effect of its own.
module Installer
  def self.install(k) = k
end
class Host; end
def make_target = Host
def make_installer = Installer
p make_target.class_eval(&make_installer.method(:install))
