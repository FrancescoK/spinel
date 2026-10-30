module OpenSSL
  # OpenSSL::Random.random_bytes, CRuby's spelling for cryptographically
  # strong bytes. They come from the CSPRNG the runtime already carries,
  # the one Cipher#random_key and securerandom draw from, rather than from
  # libcrypto's RAND_bytes: one source of entropy in a program, not two.
  # CRuby's seeding calls (seed, random_add, load_random_file) are absent;
  # the runtime's generator seeds itself from the operating system.
  module Random
    # The C side answers at most this many bytes per draw; a longer request
    # is assembled from several, as securerandom assembles one.
    MAX_DRAW = 256

    # The length is CRuby's NUM2INT: an Integer, or a Float truncated, and
    # a TypeError for anything else -- a String is not read as 0, which
    # would hand back an empty "random" token.
    def self.random_bytes(length)
      n = if length.is_a?(Integer)
        length
      elsif length.is_a?(Float)
        length.to_i
      else
        raise TypeError, "no implicit conversion of #{length.class} into Integer"
      end
      raise ArgumentError, "negative string size (or size too big)" if n < 0
      out = "".b
      left = n
      while left > 0
        take = left > MAX_DRAW ? MAX_DRAW : left
        out << Crypto.random_bin(take)
        left -= take
      end
      out
    end
  end
end
