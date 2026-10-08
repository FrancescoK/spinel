def status_of(v)
  exit(v)
rescue SystemExit => e
  [e.status, e.success?]
end

def stmt_status(v)
  exit v
  :unreached
rescue SystemExit => e
  e.status
end

p status_of([true, 1][0])
p status_of([false, 1][0])
p status_of([7, "s"][0])
p status_of([2.7, 1][0])
h = {ok: true, bad: false}
p status_of(h[:ok])
p status_of(h[:bad])
p stmt_status([false, 0][0])
p stmt_status([true, 0][0])
p stmt_status([3, 0][0])
["s", nil].each do |v|
  begin
    status_of([v, 1][0])
  rescue TypeError => e
    p e.message
  end
end
