# ipaddr

`require "ipaddr"`: IPAddr, CRuby's own `ipaddr.rb`, vendored unchanged.

- Source: the ipaddr default gem 1.2.8, as Ruby 4.0.6 ships it
  (<https://github.com/ruby/ipaddr>, tag `v1.2.8`)
- Copyright: Hajimu UMEMOTO and Akinori MUSHA, as the file's header says
- License: Ruby's (`COPYING`) or the 2-clause BSD license (`BSDL`)

Two limits come from the compiler, not from this file:

- an IPv6 address whose value passes 2**64 (`2001:db8::1`) needs
  `--int-overflow=promote`; in the default mode its arithmetic raises
  RangeError
- `IPAddr#to_range` builds a Range of IPAddr objects, which is refused at
  compile time, as a Range of any object is
