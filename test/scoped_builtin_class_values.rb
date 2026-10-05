# ::-scoped builtin class constants as first-class values (#2840), and
# stat handles reporting File::Stat (#2841).
p Math::DomainError
p Math::DomainError.superclass
p Process::Status
p Process::Status.superclass
begin; raise Math::DomainError, "d"; rescue Math::DomainError => e; p e.class; end
q = "/tmp/sp_stat_probe_#{Process.pid}"
File.write(q, "hi")
p File.stat(q).class
File.open(q) { |f| p f.stat.class }
p File.stat(q).size
File.delete(q)
