# lib/win32/overlay: what a native Windows build answers differently, read
# after the file of the same path (here builtins/gem.rb) and reopening what
# it defines; a POSIX build never reads it (see sp_win32_overlay).
module Gem
  def self.win_platform? = true
end
