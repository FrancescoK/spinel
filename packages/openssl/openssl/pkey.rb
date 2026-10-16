# OpenSSL::PKey::EC -- elliptic-curve keys, in the shape #4221 settled on:
# CRuby's names where CRuby has a spelling, raw bytes where CRuby would hand
# back a BN or an EC::Point.
#
# So `EC.generate("prime256v1")` and `key.dh_compute_key(peer)` are the names
# a CRuby program already writes, but a key's halves are Strings --
# `private_key_bytes` is the scalar, `public_key_bytes` is the X9.62
# uncompressed point, 0x04 || X || Y -- and dh_compute_key takes the peer's
# bytes rather than a Point built out of a BN. `OpenSSL::BN`, `EC::Group` and
# `EC::Point` are not here, and a program that builds one fails at COMPILE
# time the way the rest of this package's gaps do.
#
# That is a real subset, and it is a deliberate one: those three classes exist
# in CRuby to express things this runtime has no other use for, and every
# protocol that names raw EC keys -- RFC 8291 Web Push, JWK's x/y halves,
# WebAuthn, ES256 -- names them as the byte strings above. A program that
# reaches for EC::Point is already doing protocol work that has to know the
# encoding anyway.
#
# A key is its bytes, so nothing on the C side outlives a call: there is no
# handle to release and no slot to run out of, unlike the connection table
# SSLSocket holds. An abandoned key costs nothing.
module OpenSSL
  module PKey
    class PKeyError < OpenSSLError
    end

    class ECError < PKeyError
    end

    class EC
      # The curve is carried, not inferred: the byte lengths of both halves
      # follow from it, and a key whose curve is implicit has to be guessed at
      # from a length the moment two curves are in play.
      attr_reader :curve
      attr_reader :private_key_bytes
      attr_reader :public_key_bytes

      # CRuby's spelling, and CRuby's argument: the curve's name, "prime256v1"
      # for P-256. Whatever OBJ_txt2nid resolves works; anything else raises.
      def self.generate(curve)
        priv = Native.ec_generate(curve)
        raise ECError, Native.last_error if priv.empty?
        new(curve, priv)
      end

      # No CRuby spelling: CRuby reads a key from DER or PEM, and this package
      # parses neither. The bytes are what a protocol stores -- a VAPID
      # application server key is exactly this scalar, base64url'd.
      def self.from_private_bytes(curve, bytes)
        new(curve, bytes)
      end

      # A public-only key: everything a verifier has. #verify_raw works on one,
      # and #dh_compute_key and #sign_raw raise, because there is no scalar to
      # do them with. The point is checked here rather than at first use, so a
      # peer key that is not on the curve is rejected where it arrives.
      def self.from_public_bytes(curve, bytes)
        new(curve, "", bytes)
      end

      # An empty private half means "public only"; the two are never both
      # absent, and the private one wins when both are given, since the public
      # half derives from it.
      def initialize(curve, private_key_bytes, public_key_bytes = "")
        @curve = curve
        @private_key_bytes = private_key_bytes
        if private_key_bytes.empty?
          raise ECError, "a key needs a private scalar or public bytes" if public_key_bytes.empty?
          @public_key_bytes = public_key_bytes
          # The point is checked where it arrives, not at first use: an ECDSA
          # verify against something that is not on the curve must not be
          # reachable at all.
          if Native.ec_check_point(curve, public_key_bytes) != 1
            raise ECError, Native.last_error
          end
        else
          @public_key_bytes = Native.ec_public_bytes(curve, private_key_bytes)
          raise ECError, Native.last_error if @public_key_bytes.empty?
        end
      end

      # True for a key built from public bytes alone.
      def public_only?
        @private_key_bytes.empty?
      end

      # CRuby's name; CRuby takes an EC::Point and this takes the same point's
      # uncompressed bytes. The answer is identical either way: the X
      # coordinate of the product, field-width, which is what CRuby returns
      # when no KDF is asked for.
      #
      # A peer key that is not a point on this curve raises rather than
      # answering: an ECDH against an off-curve point leaks the private scalar
      # to whoever chose it.
      def dh_compute_key(peer_public_bytes)
        need_private!("dh_compute_key")
        secret = Native.ec_dh(@curve, @private_key_bytes, peer_public_bytes)
        raise ECError, Native.last_error if secret.empty?
        secret
      end

      # ECDSA, as the raw `r || s` every JOSE and WebAuthn context means by a
      # signature -- two field-width integers, 64 bytes on P-256.
      #
      # NOT SPELLED #sign, and the difference is the point. CRuby's #sign
      # answers DER, and a DER signature is a perfectly well-formed String
      # that every JWT verifier rejects: keeping CRuby's name for bytes CRuby
      # does not produce would compile a CRuby program here and fail it
      # remotely, in someone else's stack, long after the call. The argument
      # shape IS CRuby's -- a digest name and the data, not a pre-computed
      # hash -- so a caller cannot accidentally sign something unhashed.
      def sign_raw(digest, data)
        need_private!("sign_raw")
        sig = Native.ecdsa_sign(@curve, @private_key_bytes, hash_of(digest, data))
        raise ECError, Native.last_error if sig.empty?
        sig
      end

      # CRuby's #verify argument order, over the same raw signature. Answers
      # false for a signature that does not verify AND for one that is
      # malformed: a caller asking "is this good" must not be able to read
      # "the input was strange" as yes.
      def verify_raw(digest, signature, data)
        Native.ecdsa_verify(@curve, @public_key_bytes, hash_of(digest, data), signature) == 1
      end

      private

      def need_private!(what)
        raise ECError, "#{what} needs a private key; this one is public only" if public_only?
      end

      def hash_of(digest, data)
        case digest.to_s.upcase
        when "SHA256" then Digest::SHA256.digest(data)
        when "SHA1"   then Digest::SHA1.digest(data)
        else raise Digest::DigestError, "unsupported digest algorithm: #{digest}"
        end
      end

    end
  end
end

module OpenSSL
  module PKey
    # CRuby's openssl 4.0 has no class of its own here: RSAError is the
    # constant PKeyError, so `rescue OpenSSL::PKey::RSAError` and
    # `rescue OpenSSL::PKey::PKeyError` catch the same errors.
    RSAError = PKeyError

    # OpenSSL::PKey::RSA, public keys only: what a verifier holds. Built from
    # the modulus and exponent bytes, the halves a COSE key or a JWK names it
    # by. There is no CRuby spelling for that (CRuby builds one from DER or
    # PEM, which this package parses neither of), so the constructor has its
    # own name, as EC.from_public_bytes does. Verifying uses CRuby's names and
    # arguments, and answers what CRuby answers.
    class RSA
      attr_reader :n_bytes
      attr_reader :e_bytes

      def self.from_public_components(n_bytes, e_bytes)
        new(n_bytes, e_bytes)
      end

      def initialize(n_bytes, e_bytes)
        raise PKeyError, "an RSA public key needs a modulus and an exponent" if n_bytes.empty? || e_bytes.empty?
        @n_bytes = n_bytes
        @e_bytes = e_bytes
      end

      def public?
        true
      end

      def private?
        false
      end

      # PKCS#1 v1.5 over the named digest of the data: true or false, and
      # DigestError for an algorithm OpenSSL does not know, as in CRuby.
      def verify(digest, signature, data)
        md = digest_name(digest)
        answer(Native.rsa_verify(@n_bytes, @e_bytes, md, data, signature, 0, md, 0), md, md)
      end

      # PSS with MGF1. Both keywords are required, as in CRuby. salt_length
      # is :auto (read from the signature), :digest (the digest's length) or
      # an Integer; anything else is CRuby's TypeError.
      def verify_pss(digest, signature, data, salt_length:, mgf1_hash:)
        salt = case salt_length
               when :auto then -2   # RSA_PSS_SALTLEN_AUTO
               when :digest then -1 # RSA_PSS_SALTLEN_DIGEST
               when Integer then salt_length
               else raise TypeError, "no implicit conversion of #{salt_length.class} into Integer"
               end
        md = digest_name(digest)
        mgf1 = digest_name(mgf1_hash)
        answer(Native.rsa_verify(@n_bytes, @e_bytes, md, data, signature, 1, mgf1, salt), md, mgf1)
      end

      private

      # CRuby takes the algorithm as its name or as an OpenSSL::Digest.
      def digest_name(digest)
        digest.is_a?(OpenSSL::Digest) ? digest.name : digest.to_s
      end

      # The native call answers 1 for a good signature, 0 for a bad one, -1
      # when the digest name resolves to nothing and -2 for the MGF1 one.
      def answer(rc, md, mgf1)
        raise OpenSSL::Digest::DigestError, "unsupported digest algorithm: #{md}" if rc == -1
        raise OpenSSL::Digest::DigestError, "unsupported digest algorithm: #{mgf1}" if rc == -2
        rc == 1
      end
    end
  end
end
