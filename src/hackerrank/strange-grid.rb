# /bin/ruby

# URL: https://www.hackerrank.com/challenges/strange-grid
#  0  2  4  6  8
#  1  3  5  7  9
# 10 12 14 16 18
# 11 13 15 17 19
# 20 22 24 26 28
# ..............
# ..............

r, c = gets.strip.split(' ').map {|n| n.to_i}

# Observation: values may be calculated as follows:
# 10 * ((r - 1) / 2) + ((c - 1) << 1) + ((r - 1) % 2)
# Caveat: I'm thinking this is too easy: tests may fail due to timeout...
# Will probably need to optimize.

puts (10 * ((r - 1) / 2) + ((c - 1) << 1) + ((r - 1) % 2))

# vim:ts=4:sw=4:et:tw=120
