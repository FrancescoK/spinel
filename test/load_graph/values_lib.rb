# Writes of main's instance variable, a global and a constant in a required
# file, which values_main.rb reads before and after its require; and reads
# of the ones main writes only after the require.
@level = 2
$total = 10
LIMIT = 7
p defined?(@early)
p $late
p defined?(LATE)
