# spinel: not-cruby -- OpenSSL::PKey::RSA.from_public_components has no CRuby spelling; the expected answers are CRuby's verify / verify_pss on the same key built from DER
require "openssl"

def hx(s) = [s].pack("H*")

# A 1024-bit key and signatures made by CRuby's sign / sign_pss with the
# private half, which this package does not have.
n = hx("a858eec8631af4f0ed368b7b7012cf9a42729fb9f877acec2722a841b6346105d76bc6994e55a988660a680dcb76be0dad76c744b4b53aad5d81bd08e11ccc8d672589c94288e55a21d900158433aa151fa957c3eb9f36d7b3a8591d739c2eeecedc1c8341aca74423af0673f78708e13adc08de48b46482a0ae8296b45dd0f3")
e = hx("010001")
data = hx("61757468656e74696361746f722064617461207c7c20636c69656e7420646174612068617368200002")
v15_256 = hx("25dade0cdcf0b948118e11c6518e4e2e160d011674607583be9c026708226ba637e368e343148201b8c378c4566edfe7effe8b499cf17c562f3dcbd73cbdffb1437bbc1abd37f60afb883561b217d8a4693368923739846db8d4fe049822fe95fc231d9bdfa69178f67ff0d5b66873b31e3f132fad38e56a02c2436551200587")
v15_384 = hx("1a037ec6d6c4e2dd0b977e7afac95dd0da62adbfa122b6a7d35642b38c896b1b4ebe62b96779fd0fa705d295b8edec9210f4c1dfd62ce0ca9bd8107b8fee77a3be6a95ae67fc15b6fbe45cd7de2b4ebf141225f469a659bdc451262a6928c66ce83c57dd50e349e27d78188bbff0981f38bbcf9ead525e902f7a5f19d66b0ff3")
pss20 = hx("a635bdcd8ac4b497877453cb051558c6ecf8b7667f9d7be9491a26e1bcd331eef6b7ba6cf2a4ba4f7b19edbc54707f612f018a6345bfe30cd7ac5578d428f68c617cc1a5177e486ca14ba4d1b8a1c230010d76cecf2d485a8c15d50eacb68f7adc21360b60f067fab14e2f9ffc192741f02766adab4937fc18af6ed6992126b3")
pss_digest = hx("725ad5fbfa0c2f537a5fbb4aa698997d1af18ae6201a09a585bbe6aaea2a0706823328d2c6215885034860e5c31a0a6be79acbbf5e35f0de2e9818c36b065726cfa902f565d5ddbca31a2e605259493b0d8b6f10d74a56f3d1cdd2489faf3eb38f5154e85ee65ce3e19b391e88e97f7c8df84090a991ef0b08a5df5a383c0b1a")
key = OpenSSL::PKey::RSA.from_public_components(n, e)

# PKCS#1 v1.5: the digest by name in any case, or as an OpenSSL::Digest.
p key.verify("SHA256", v15_256, data)
p key.verify("sha256", v15_256, data)
p key.verify(OpenSSL::Digest.new("SHA256"), v15_256, data)
p key.verify("SHA384", v15_384, data)
p key.verify("SHA256", v15_384, data)
p key.verify("SHA256", "short", data)

# PSS: a fixed salt length and an MGF1 digest of its own, :auto, :digest.
p key.verify_pss("SHA256", pss20, data, salt_length: 20, mgf1_hash: "SHA1")
p key.verify_pss("SHA256", pss20, data, salt_length: :auto, mgf1_hash: "SHA1")
p key.verify_pss("SHA256", pss20, data, salt_length: 32, mgf1_hash: "SHA1")
p key.verify_pss("SHA256", pss20, data, salt_length: :auto, mgf1_hash: "SHA256")
p key.verify_pss("SHA384", pss_digest, data, salt_length: :digest, mgf1_hash: "SHA384")
p key.verify_pss("SHA384", pss_digest, data + "x", salt_length: :digest, mgf1_hash: "SHA384")

# An algorithm OpenSSL does not know raises, as CRuby's does; so does a salt
# length that is neither a length nor :auto / :digest.
begin
  key.verify("MD7", v15_256, data)
rescue OpenSSL::Digest::DigestError => e
  p e.class
end
begin
  key.verify_pss("SHA256", pss20, data, salt_length: :auto, mgf1_hash: "MD7")
rescue OpenSSL::Digest::DigestError => e
  p e.class
end
begin
  key.verify_pss("SHA256", pss20, data, salt_length: :max, mgf1_hash: "SHA1")
rescue TypeError => e
  puts e.message
end

p key.public?
p key.private?
p OpenSSL::PKey::RSAError.equal?(OpenSSL::PKey::PKeyError)
