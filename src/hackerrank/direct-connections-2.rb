# /bin/ruby

# URL: https://www.hackerrank.com/challenges/direct-connections/submissions/code/11743686
# Note: Initial submission timed out on several test cases.
# Optimizations:
# -Pre-sort the cities by population (descending) so we don't need to check for min in nested loop.
# -Don't perform multiplications in inner loop; maintain hash mapping distances to # of cables spanning that distance,
#  and perform a single multiplication per hash entry after loop termination.

def read_block
  [
    gets.strip.to_i,
    gets.strip.split(' ').map {|v| v.to_i},
    gets.strip.split(' ').map {|v| v.to_i}
  ]
end

T = gets.strip.to_i
(0...T).each {|tc|
  # Read n, [dist1, ...], [pop1, ...]
  n, dists, pops = read_block
  # Create zipped list: [[dist1, pop1], ...]
  cities = dists.zip pops
  # Sort by population, descending
  cities = cities.sort do |a, b|
    b[1] <=> a[1]
  end

  # Hash mapping distances to # of cables spanning that distance
  d2c = Hash.new 0
  # Loop over city pairs
  (0...n-1).each {|i|
    d1, p1 = cities[i]
    (i+1...n).each {|j|
      d2 = cities[j][0]
      d = (d1 - d2).abs
      d2c[d] += p1
    }
  }
  dist = 0
  d2c.to_a.each {|d, c|
    dist = (dist + (d * c)) % 1_000_000_007
  }
  puts dist.class
  puts dist
}


# vim:ts=2:sw=2:et:tw=120
