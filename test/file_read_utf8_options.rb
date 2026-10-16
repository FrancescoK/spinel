# File.read naming UTF-8 as the encoding (encoding:, external_encoding:,
# internal_encoding:) reads the text as the plain call does: the options
# hash is not a length
path = "file_read_utf8_options_tmp.txt"
File.write(path, "café\tb\n")
p File.read(path, external_encoding: Encoding::UTF_8, internal_encoding: Encoding::UTF_8)
p File.read(path, encoding: "UTF-8")
p File.read(path, encoding: Encoding::UTF_8).size
p File.read(path, 3)
File.delete(path)
