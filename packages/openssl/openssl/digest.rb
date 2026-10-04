# OpenSSL::Digest and OpenSSL::HMAC -- the names a CRuby program writes for a
# hash or a signature, over the hashes the runtime already carries
# (lib/sp_crypto.c, the same implementations the `digest` package binds).
# Nothing here reaches libssl: these are not the TLS surface, they are the
# other half of the OpenSSL namespace that programs name, and there is no
# reason to route them through a second implementation.
#
# The class-method forms (`OpenSSL::Digest::SHA256.hexdigest(data)`) and the
# object (`OpenSSL::Digest.new("SHA256")`, `OpenSSL::Digest::SHA256.new`)
# with update / << / digest / hexdigest / reset / digest_length / name. The
# object buffers what it is given and hashes it whole when asked, over the
# same one-shot functions: the runtime's hashes have no streaming state.
module OpenSSL
  # CRuby's base for everything in this namespace; SSLError and DigestError
  # both descend from it, so `rescue OpenSSL::OpenSSLError` catches either.
  class OpenSSLError < StandardError
  end

  module Crypto
    native_lib "openssl"
    native_func :sha256_hex,      [:string],          :cstring, "sp_crypto_sha256_hex"
    native_func :sha256_bin,      [:string],          :cbinstr, "sp_crypto_sha256_bin"
    native_func :sha1_hex,        [:string],          :cstring, "sp_crypto_sha1_hex"
    native_func :sha1_bin,        [:string],          :cbinstr, "sp_crypto_sha1_bin"
    native_func :md5_hex,         [:string],          :cstring, "sp_crypto_md5_hex"
    native_func :md5_bin,         [:string],          :cbinstr, "sp_crypto_md5_bin"
    native_func :hmac_sha256_hex, [:string, :string], :cstring, "sp_crypto_hmac_sha256_hex"
    native_func :hmac_sha1_hex,   [:string, :string], :cstring, "sp_crypto_hmac_sha1_hex"
    native_func :hmac_sha256_bin, [:string, :string], :cbinstr, "sp_crypto_hmac_sha256_bin"
    native_func :hmac_sha1_bin,   [:string, :string], :cbinstr, "sp_crypto_hmac_sha1_bin"
    # The CSPRNG the runtime already carries, for Cipher#random_key /
    # #random_iv. Nothing here reaches libssl, so a key or an IV is drawn
    # from the same source `securerandom` uses rather than a second one.
    native_func :random_bin,      [:int],             :cbinstr, "sp_crypto_random_bin"
  end

  class Digest
    class DigestError < OpenSSLError
    end

    # The one-shot hash of `data` under algorithm `name` (as CRuby spells it,
    # any case), raw; the hashes the runtime carries, and DigestError for the
    # rest, the class CRuby raises for an unknown algorithm.
    def self.raw(name, data)
      case name.to_s.upcase
      when "SHA256" then Crypto.sha256_bin(data)
      when "SHA1"   then Crypto.sha1_bin(data)
      when "MD5"    then Crypto.md5_bin(data)
      else raise DigestError, "Unsupported digest algorithm (#{name}).: unknown object name"
      end
    end

    def self.length_of(name)
      case name.to_s.upcase
      when "SHA256" then 32
      when "SHA1"   then 20
      when "MD5"    then 16
      else raise DigestError, "Unsupported digest algorithm (#{name}).: unknown object name"
      end
    end

    def initialize(name, data = nil)
      @name = name.to_s.upcase
      Digest.length_of(@name)
      @buf = String.new(encoding: Encoding::BINARY)
      @buf << data if data
    end

    def name = @name
    def digest_length = Digest.length_of(@name)
    def block_length = 64

    def update(data)
      @buf << data
      self
    end
    alias << update

    def reset
      @buf = String.new(encoding: Encoding::BINARY)
      self
    end

    def digest(data = nil)
      return Digest.raw(@name, data) if data
      Digest.raw(@name, @buf)
    end

    def hexdigest(data = nil) = digest(data).unpack1("H*")

    class SHA256 < Digest
      def initialize(data = nil) = super("SHA256", data)
      def self.hexdigest(data) = Crypto.sha256_hex(data)
      def self.digest(data)    = Crypto.sha256_bin(data)
    end

    class SHA1 < Digest
      def initialize(data = nil) = super("SHA1", data)
      def self.hexdigest(data) = Crypto.sha1_hex(data)
      def self.digest(data)    = Crypto.sha1_bin(data)
    end

    # A legacy hash, carried because Active Storage's direct upload checks a
    # blob by its MD5 (#4631). Not for new designs.
    class MD5 < Digest
      def initialize(data = nil) = super("MD5", data)
      def self.hexdigest(data) = Crypto.md5_hex(data)
      def self.digest(data)    = Crypto.md5_bin(data)
    end
  end

  module HMAC
    # CRuby takes the algorithm first, as a String or a Digest instance. Only
    # the String form is here, and only for the two the runtime carries: an
    # algorithm that is not one of them raises DigestError -- the class CRuby
    # raises, so `rescue OpenSSL::Digest::DigestError` catches the same thing
    # -- rather than answering a hash from the wrong function. HMAC-MD5 is one
    # of those: CRuby has it, the runtime's crypto does not (its MD5 is the
    # digest alone).
    def self.hexdigest(algo, key, data)
      case algo.to_s.upcase
      when "SHA256" then Crypto.hmac_sha256_hex(key, data)
      when "SHA1"   then Crypto.hmac_sha1_hex(key, data)
      else raise Digest::DigestError, "unsupported digest algorithm: #{algo}"
      end
    end

    # The same MAC as its own bytes. `Digest::SHA256` has had both spellings
    # since this file was written; HMAC had only the hex one, which is the
    # half a human or a header reads.
    #
    # The raw half is what another primitive reads. HKDF (RFC 5869) is HMAC
    # over raw bytes twice, and a caller with only hex has to decode between
    # the two rounds -- a lossless detour with a chance to get the decode
    # wrong. The same is true of anything comparing a MAC to bytes off a
    # wire: a webhook signature, a JWT's HS256 half, an AWS SigV4 chain.
    #
    # Same algorithm set and the same refusal as `hexdigest`: whatever one
    # answers, the other answers.
    def self.digest(algo, key, data)
      case algo.to_s.upcase
      when "SHA256" then Crypto.hmac_sha256_bin(key, data)
      when "SHA1"   then Crypto.hmac_sha1_bin(key, data)
      else raise Digest::DigestError, "unsupported digest algorithm: #{algo}"
      end
    end
  end
end
