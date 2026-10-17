# spinel: not-cruby -- PKey::EC's curve, key bytes, sign_raw and verify_raw have no CRuby spelling, and PKey.read refuses the RSA, Ed25519 and DH keys and the EC parameters CRuby reads; the key bytes below are what CRuby's private_key and public_key give for the same PEM
require "openssl"

# The test key of openssl_pkey_read.rb, made for these tests and used nowhere
# else.
SEC1_PEM = <<~PEM
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIPIRlQfBz7+HavOzW8H69dntBcUZ0MicF3/FxGctM0W1oAoGCCqGSM49
AwEHoUQDQgAEt359v/oOHu/SPzBOr2L2kyeBh0FqfJEb4bHSE1VYY91cbq+WbMQM
1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END EC PRIVATE KEY-----
PEM
PUBLIC_PEM = <<~PEM
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEt359v/oOHu/SPzBOr2L2kyeBh0Fq
fJEb4bHSE1VYY91cbq+WbMQM1KGlLMHKROfZ91RoFSV2fI4BbN02mscXYA==
-----END PUBLIC KEY-----
PEM
RSA_PEM = <<~PEM
-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALsNpFNYkNXQkxGW
/cPwbZFaTvZZXEooubjT6wJCzUJYACl/jH1z1Z3Ddej3vJw60bLzdL9tffXgtLuV
L0/W2ed5Gh6GsGCw2pNN7v2vH+fXLNYE6r/dMHRkNmF8AnELIJRfxONemxr0uMkq
a8hZTMELMTJs/zbVc2JkOerMupqxAgMBAAECgYACvXBqyCFXAHcnCs8sz5jLSEdf
1G9FptMRogkPP2tCTYezE+s66zd12CciAn8AytvHg0lyhGgT8fazyLuor70BYJpO
x+owYO0N/HobbSM7iIih/exRrfPnuslV/AbuYFOGuYuB6mtdtqQre39COjXTdpcS
thlZCnUlQasw5n0EAQJBAON+2uZ82LuOnCSIwTO7NiJ6p1/jN19U7JqG7sWwiIu5
N0Psr//5O8y3J105WHeopnfuk7AtqBWb1VdkWVFL6wUCQQDSfY/VRqcgpdsFG5hq
ry6Rc6Rc8k5JKxTvzRvy4DNcw1mfhBPsKDx81mYoMws5F+yY+9993pZEl6CQ+0iA
QTi9AkB3nazFgiGHRK3O++TyKV6GdI1q+pKT2phpi8ciRPcW2HU5jsrfwZFyy160
QsHEcPXOm7Al82usqPpc8BOSjmNtAkBIF3UhyNcI2YVQFIl5UJKUgpTyuJKTgMvk
7cz6vEsbJFUXyza/lXBSGWRXtFPNtCH2q516ELhKudvmjAni03PJAkEA1mpFTWqo
S8wOAOxdd6koC26Kc6TvBWHVJPNRzfMMp27UoTJkI2kihU17DtKEm2CH9Ca7OGDA
SwQu38SyNmJM2g==
-----END PRIVATE KEY-----
PEM
ED25519_PEM = <<~PEM
-----BEGIN PRIVATE KEY-----
MC4CAQAwBQYDK2VwBCIEIMP88ZqEGaagCHly59xSdb6Nh5XQEOK3OA81yj9frZVZ
-----END PRIVATE KEY-----
PEM
# RSA_PEM's public half in PKCS#1, not the PUBLIC KEY form.
RSA_PUBLIC_PEM = <<~PEM
-----BEGIN RSA PUBLIC KEY-----
MIGJAoGBALsNpFNYkNXQkxGW/cPwbZFaTvZZXEooubjT6wJCzUJYACl/jH1z1Z3D
dej3vJw60bLzdL9tffXgtLuVL0/W2ed5Gh6GsGCw2pNN7v2vH+fXLNYE6r/dMHRk
NmF8AnELIJRfxONemxr0uMkqa8hZTMELMTJs/zbVc2JkOerMupqxAgMBAAE=
-----END RSA PUBLIC KEY-----
PEM
# Parameters with no key in them. CRuby reads the first as a PKey::DH, and
# the second as a PKey::EC with neither half.
DH_PEM = <<~PEM
-----BEGIN DH PARAMETERS-----
MEkCQQDambzLuPNchurung0+RRRfgEUT+0hEECLUjNrslsJ6cvUqEk1i1unPp4jv
UG6rb1roiXVYHgpKN3bio7D5xJ7HAgECAgF9
-----END DH PARAMETERS-----
PEM
EC_PARAMETERS_PEM = <<~PEM
-----BEGIN EC PARAMETERS-----
BggqhkjOPQMBBw==
-----END EC PARAMETERS-----
PEM
# SEC1_PEM encrypted with the passphrase "Ttukseom". PKey.read takes no
# passphrase, so this is a key that does not parse, and nothing prompts.
ENCRYPTED_PEM = <<~PEM
-----BEGIN EC PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: AES-128-CBC,D3F090434C2A8AEF0FF58DA44E5F065F

EFHHIuLqTt40BkNyHkWnRf111XdbVXrP4Y7NQ9trlBv0fFTK0OgJ847gtl6tqbb6
Hot0eTkvcnGEnJyQxxJ4GPNkA98X6Z14KuIYo4X2nifbD3hddmTPY1Ehpb9sbVnR
ihw9KA5XnGnCy4QluGJH6Xjp3APKw082CUSDZjuH25M=
-----END EC PRIVATE KEY-----
PEM

key = OpenSSL::PKey.read(SEC1_PEM)
p key.curve
# CRuby: key.private_key.to_s(2) and key.public_key.to_octet_string(:uncompressed)
p key.private_key_bytes.unpack1("H*")
p key.public_key_bytes.unpack1("H*")

pub = OpenSSL::PKey.read(PUBLIC_PEM)
p pub.public_only?, pub.public_key_bytes == key.public_key_bytes

# A key read from PEM signs and verifies like one built from its bytes.
sig = key.sign_raw("SHA256", "Mapo Bridge to Yeouido")
p pub.verify_raw("SHA256", sig, "Mapo Bridge to Yeouido")
p pub.verify_raw("SHA256", sig, "Mapo Bridge to Hapjeong")
p OpenSSL::PKey::EC.from_private_bytes("prime256v1", key.private_key_bytes).public_key_bytes == key.public_key_bytes

[RSA_PEM, ED25519_PEM, ENCRYPTED_PEM, RSA_PUBLIC_PEM, DH_PEM, EC_PARAMETERS_PEM].each do |pem|
  begin
    OpenSSL::PKey.read(pem)
  rescue OpenSSL::PKey::PKeyError => e
    p e.message
  end
end
