# A program that defines a module named like a bundled library's class
# (`Digest`, `JSON`, `Set`...) under TWO namespaces -- the collision
# qualifier then registers each under its path -- and refers to one of them
# bare from inside its namespace, as Ruby's lexical lookup allows. The
# bundled-library gate ("add `require \"digest\"`") only looked for the bare
# leaf and refused the reference; a definition under any path is the
# program's own. activesupport defines ActiveSupport::Digest beside the
# openssl package's OpenSSL::Digest, whose HMAC raises Digest::DigestError.
module Wrap
  module Digest
    class DigestError < StandardError; end
    def self.name_of = "wrap"
  end
  module HMAC
    def self.check(algo)
      raise Digest::DigestError, "unsupported digest algorithm: #{algo}" unless algo == "SHA256"
      "ok:#{Digest.name_of}"
    end
  end
end
module Other
  class Digest
    def self.name_of = "other"
  end
end
p Wrap::HMAC.check("SHA256"), Other::Digest.name_of, Wrap::Digest.name_of
begin
  Wrap::HMAC.check("MD5")
rescue Wrap::Digest::DigestError => e
  puts "DigestError: #{e.message}"
end
