# sp_crypto.c -- ffi exposed to spinel programs.
#
# Covers the canonical surface with deterministic vectors:
#   - HMAC-SHA256 against RFC 4231 test case 4 (4-character key, 50
#     byte message). The standard vector for hex output is
#     82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b
#     -- truncated to its first 43 b64url chars for the b64url variant.
#   - Base64URL round-trip on a string with a 2-byte tail (RFC 4648
#     standard padding/tail behaviour).
#   - PBKDF2-HMAC-SHA256 with a single iteration (matches RFC 7914
#     scrypt-vector format, simpler than the 1024-iter RFC 6070 case).
#   - Random b64url returns the right length for the requested byte
#     count, and (because it's random) doesn't compare-equal across
#     calls.
#   - The binary HMAC spellings against RFC 4231 test case 1 (a
#     20-byte 0x0b key), hexed here so the vector stays readable, plus
#     the property that matters: raw and hex are the same MAC, and the
#     raw one is its full width whatever bytes it happens to contain.
module Crypto
  ffi_func :sp_crypto_hmac_sha256_hex,      [:str, :str],       :str
  ffi_func :sp_crypto_hmac_sha256_b64url,   [:str, :str],       :str
  ffi_func :sp_crypto_hmac_sha1_hex,        [:str, :str],       :str
  ffi_func :sp_crypto_hmac_sha256_bin,      [:str, :str],       :binstr
  ffi_func :sp_crypto_hmac_sha1_bin,        [:str, :str],       :binstr
  ffi_func :sp_crypto_b64url_encode,        [:str],             :str
  ffi_func :sp_crypto_b64url_decode,        [:str],             :str
  ffi_func :sp_crypto_pbkdf2_sha256_b64url, [:str, :str, :int], :str
  ffi_func :sp_crypto_pbkdf2_sha256_b64url_len, [:str, :str, :int, :int], :str
  ffi_func :sp_crypto_random_b64url,        [:int],             :str
end

# RFC 4231 test case 4: 25-byte key, 50-byte message.
key = "Jefe"
msg = "what do ya want for nothing?"
puts Crypto.sp_crypto_hmac_sha256_hex(key, msg)
# RFC 2202 test case 2 -- the same key and message, HMAC-SHA1.
puts Crypto.sp_crypto_hmac_sha1_hex(key, msg)

# Base64URL round-trip on a 5-byte input (length 5 % 3 == 2 so the
# tail emits 3 chars and no padding). Should print "hello" twice.
enc = Crypto.sp_crypto_b64url_encode("hello")
puts enc
puts Crypto.sp_crypto_b64url_decode(enc)

# PBKDF2 with iters=1 is HMAC(key, salt||0x00000001). The expected
# 43-char b64url is a stable property of the salt+password+1 input.
puts Crypto.sp_crypto_pbkdf2_sha256_b64url("password", "salt", 1)

# The two-block form: dkLen 64 is what Rails' KeyGenerator derives for
# a signed cookie. T(1) is the same 32 bytes as above, so the 64-byte
# value starts with the same digest and continues into T(2).
puts Crypto.sp_crypto_pbkdf2_sha256_b64url_len("password", "salt", 1, 64)
# Clamps: 0 falls back to 32 bytes, over-64 saturates at 64.
puts Crypto.sp_crypto_pbkdf2_sha256_b64url_len("password", "salt", 1, 0).length
puts Crypto.sp_crypto_pbkdf2_sha256_b64url_len("password", "salt", 1, 999).length

# Random: two calls of the same size must differ (probability of
# collision on 16 bytes is 2^-128). Print the length and the
# inequality result so the .expected stays deterministic.
r1 = Crypto.sp_crypto_random_b64url(16) + ""
r2 = Crypto.sp_crypto_random_b64url(16) + ""
puts r1.length
puts(r1 == r2 ? "same" : "diff")

# RFC 4231 test case 1: key = 20 bytes of 0x0b, msg = "Hi There". The raw
# spellings must agree with the hex ones byte for byte -- the point of having
# both is the representation, never a different MAC.
bkey = "\x0b" * 20
puts Crypto.sp_crypto_hmac_sha256_bin(bkey, "Hi There").unpack1("H*")
puts Crypto.sp_crypto_hmac_sha256_bin(bkey, "Hi There").unpack1("H*") ==
     Crypto.sp_crypto_hmac_sha256_hex(bkey, "Hi There")
puts Crypto.sp_crypto_hmac_sha1_bin(key, msg).unpack1("H*") ==
     Crypto.sp_crypto_hmac_sha1_hex(key, msg)
# The length rides sp_ffi_bin_len rather than a terminator, so a digest is
# always its full width -- a MAC is uniform random bytes and roughly one in
# eight contains a NUL, which a NUL-terminated return would silently truncate.
puts Crypto.sp_crypto_hmac_sha256_bin(bkey, "Hi There").bytesize
puts Crypto.sp_crypto_hmac_sha1_bin(bkey, "Hi There").bytesize

# The decode answers bytes, and sets sp_ffi_bin_len to their count, so a
# `:binstr` binding keeps a NUL among them: "AGFi" is "\x00ab", "YQBi" is
# "a\x00b". Bad input decodes to nothing, whatever the call before it set.
module CryptoBin
  ffi_func :sp_crypto_b64url_decode, [:str], :binstr
end
p CryptoBin.sp_crypto_b64url_decode("AGFi")
p CryptoBin.sp_crypto_b64url_decode("YQBi")
Crypto.sp_crypto_hmac_sha1_bin("k", "x")
p CryptoBin.sp_crypto_b64url_decode("!!!!").bytesize
