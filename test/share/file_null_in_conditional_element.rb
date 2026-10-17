# File::NULL and the separators are frozen Strings, one each (static
# literals), so `inf || File::NULL` into a Hash literal beside a String
# the program changes takes each arm as it is: the open3 package's
# capture, refused under --share-strings.
def run(data)
  inf = data ? File.join("/tmp", "in") : nil
  opts = { out: "o", in: inf || File::NULL }
  inf << "!" if inf
  p opts, inf
end
run("x")
run(nil)
