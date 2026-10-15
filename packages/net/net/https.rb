# `require "net/https"` -- the name older code still asks for. In CRuby it has
# been a shim since 2.0: net/http itself speaks https, and this file only adds
# openssl, which an https request through this package needs too.
require "net/http"
require "openssl"
