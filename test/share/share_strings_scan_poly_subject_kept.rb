# A scan whose subject is only known as a boxed value binds each match as a
# shared handle of its own when the rule shares the matches, so a match the
# program keeps and changes after the scan is the one the Array holds.

# a boxed local subject, the matches kept and changed after the scan
boxed = [+"abc", 1].first
boxed_kept = []
boxed.scan(/./) { |bm| boxed_kept << bm }
boxed_kept[0] << "!"
p boxed_kept, boxed
