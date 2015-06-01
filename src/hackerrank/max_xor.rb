#!/usr/bin/ruby
def maxXor(l, r)
    max = l ^ r
    (l..r).each do |a|
        (a..r).each do |b|
            if a ^ b > max
                max = a ^ b
            end
        end
    end
    max
end
l = gets.to_i
r = gets.to_i
print maxXor(l, r)

# vim:ts=4:sw=4:et:tw=120
