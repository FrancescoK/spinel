# OpenSSL::Random.random_bytes in a program that only ever passes it an
# Integer, a computed one included: the length check folds to its Integer
# arm, and the method still compiles and answers that many bytes.
require "openssl"

p OpenSSL::Random.random_bytes(1).bytesize
p OpenSSL::Random.random_bytes(OpenSSL::Random.random_bytes(1).bytesize + 256).bytesize
p [0, 16, 1024].map { |n| OpenSSL::Random.random_bytes(n).bytesize }
