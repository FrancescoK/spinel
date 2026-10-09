s = +"abc"
t = s
[s].chunk_while { |a, b| true }.each { |ch| ch[0] << "!" }
p s
p t
