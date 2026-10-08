# Regression for #1417. An RBS `--rbs` seed for a *module-nested* class must
# reach the class. `Outer::Box#@label` is declared `String?`, but the body only
# ever assigns nil, so inference alone leaves the ivar poly (`sp_RbVal`). Only
# the seed pins it to a `String` (`const char *`) field.
#
# The extractor emits the seed under the qualified name `Outer_Box`, but the
# compiler stores the class under its leaf name `Box` (+ enclosing_class). Before
# the fix, seed_class_index matched by exact name only, so the qualified seed
# name found nothing and every module-nested class's ivar/method seeds were
# silently dropped -- here, `@label` stayed poly instead of pinning to a string.
# spinel: rbs-seed-check
module Outer
  class Box
    def initialize
      @label = nil
    end
    def label
      @label
    end
  end
end

p Outer::Box.new.label.nil?
