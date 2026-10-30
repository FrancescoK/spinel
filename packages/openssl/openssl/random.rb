module OpenSSL
  # OpenSSL::Random.random_bytes, CRuby's spelling for cryptographically
  # strong bytes. They come from the CSPRNG the runtime already carries,
  # the one Cipher#random_key and securerandom draw from, rather than from
  # libcrypto's RAND_bytes: one source of entropy in a program, not two.
  # CRuby's seeding calls (seed, random_add, load_random_file) are absent;
  # the runtime's generator seeds itself from the operating system.
  module Random
    def self.random_bytes(length)
      n = length.to_i
      raise ArgumentError, "negative string size (or size too big)" if n < 0
      return "".b if n == 0
      Crypto.random_bin(n)
    end
  end
end
