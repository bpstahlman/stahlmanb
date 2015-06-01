# /bin/ruby

require "rbtree"

rbtree = RBTree["c", 10, "a", 20]
rbtree["b"] = 30
p rbtree["b"]              # => 30
rbtree.each do |k, v|
  p [k, v]
end                        # => ["a", 20] ["b", 30] ["c", 10]

mrbtree = MultiRBTree["c", 10, "a", 20, "e", 30, "a", 40]
p mrbtree.lower_bound("b") # => ["c", 10]
mrbtree.bound("a", "d") do |k, v|
  p [k, v]
end   

ds = %w(1  3  4  6 7  9)
ps = %w(10 15 12 9 18 15)

# vim:ts=2:sw=2:et:tw=120

