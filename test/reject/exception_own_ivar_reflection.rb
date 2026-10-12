# An exception class that defines instance_variables itself answers it, which
# the reflection on a rescued exception would skip, so it stays refused.
class MyErr < StandardError
  def instance_variables; [:fake]; end
end
begin
  raise MyErr, "m"
rescue => e
  p e.instance_variables
end
