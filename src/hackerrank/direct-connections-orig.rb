# /bin/ruby

def read_block
  [
    gets.strip.to_i,
    gets.strip.split(' ').map {|v| v.to_i},
    gets.strip.split(' ').map {|v| v.to_i}
  ]
end

T = gets.strip.to_i
(0...T).each {|tc|
  n, dists, pops = read_block
  cable = 0
  # Loop over pairs
  (0...n-1).each {|i|
    (i+1...n).each {|j|
      max_pop = [pops[i], pops[j]].max
      cable += max_pop * (dists[j] - dists[i]).abs
    }
  }
  puts cable % 1_000_000_007
}


# vim:ts=2:sw=2:et:tw=120
