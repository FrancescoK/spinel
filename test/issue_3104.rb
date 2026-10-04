path = "/tmp/spinel_issue_3104_#{Process.pid}.txt"
File.write(path, "x")
File.open(path) { |f| p f.chown(nil, nil) }
File.delete(path)
