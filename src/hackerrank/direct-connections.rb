# /bin/ruby

# URL: https://www.hackerrank.com/challenges/direct-connections/submissions/code/11743686
# Note: Initial submission timed out on several test cases.
# Optimizations:
# -Pre-sort the cities by population (descending) so we don't need to check for min in nested loop.
# -Don't perform multiplications in inner loop; maintain hash mapping distances to # of cables spanning that distance,
#  and perform a single multiplication per hash entry after loop termination.

require 'set'
require 'rbtree'

# TODO: Use upper_bound method - Implement approach sketched out on paper with key 0abd23klkfs...

def read_block
  [
    gets.strip.to_i,
    gets.strip.split(' ').map {|v| v.to_i},
    gets.strip.split(' ').map {|v| v.to_i}
  ]
end

class CacheInfo
  public
  attr_accessor :cable_len, :cable_len_cum, :n, :dup, :city_idx
  def initialize(cfg = {})
    @cable_len = cfg[:cable_len] || 0
    @cable_len_cum = cfg[:cable_len_cum] || @cable_len
    @n = cfg[:n] || 0
    # Note: No meaningful default for city_idx
    @city_idx = cfg[:city_idx]
    @dup = nil
  end
end

# Prototype method...
def sum_cable_len(cities)
  sum = 0
  2.times do |iter|
    rbt = RBTree[]
    cities = iter == 0 ? cities : cities.map {|c| [-c[0], c[1]]}.reverse
    cities.each_with_index {|city, ci|
      pos, pop = city
      #puts "pos, pop = #{pos}, #{pop}"
      # Initialize values that may be updated from cache.
      cable_len, n, start_idx = 0, 0, 0
      cached = rbt.upper_bound pop
      #puts "cached: #{cached}"
      if cached
        # Deconstruct the key/value array returned by upper_bound
        cached_pop, cached = cached
        cached_pos = cities[cached.city_idx][0]
        cached_pos_diff = pos - cached_pos
        # Initialize cable_len from cached_info; then update in loop beginning at start_idx.
        # Note: For sake of efficiency, we account for the current city here, not in loop.
        # TODO: Encapsulate all this in a smarter class.
        # TODO: As we go, build some sort of data structure that keeps up with brackets, allowing us quickly to
        # enumerate the cities to one side of a position, with population under a limit.
        # Issue!!!: Working on the test cases, but not on large one: could it be modulo stuff broken? NO! Tested without
        # taking modulo till end, and got same (wrong) answers (but more slowly). I'm at around 21 s without the
        # optimization in earlier TODO... I'm thinking it's doable, but need to correct issue before looking at
        # optimization.
        dup = nil
        if iter == 1 && cached_pop == pop
          n = cached.n
          cable_len_base = cached.cable_len
          dup = true
        elsif iter == 1 && cached.dup
          n = cached.dup[:n] + 1
          cable_len_base = cached.dup[:cable_len]
        else
          n = cached.n + 1
          cable_len_base = cached.cable_len
        end
        n = n % 1_000_000_007 if n >= 1_000_000_007
        cable_len = cable_len_base + n * cached_pos_diff
        cable_len %= 1_000_000_007 if cable_len >= 1_000_000_007
        if dup
          # Set to actual object.
          # BUG!!!!: Not taking existing dup into account!!!!!
          dup = {
            n: n + 1,
            cable_len: cable_len + cached_pos_diff
          }
          dup[:n] %= 1_000_000_007 if dup[:n] >= 1_000_000_007
          dup[:cable_len] %= 1_000_000_007 if dup[:cable_len] >= 1_000_000_007
        end
        start_idx = cached.city_idx + 1
      end
      # Account for cities between current and cached (or left/right-most).
      # Note: We've already accounted for the cached position.
      # TODO: Faster way to sum only smaller population cities.
      n_acc = 0
      (start_idx...ci).each {|i|
        other_pop = cities[i][1]
        next if iter == 0 ? other_pop > pop : other_pop >= pop
        #puts "Updating cable_len..."
        # TODO: Update once with modulo after loop.
        cable_len = cable_len + pos - cities[i][0]
        cable_len %= 1_000_000_007 if cable_len >= 1_000_000_007
        n_acc += 1
      }
      n += n_acc
      n = n % 1_000_000_007 if n >= 1_000_000_007

      if !cached || cached_pop != pop
        # Add to cache
        rbt[pop] = CacheInfo.new cable_len: cable_len, n: n, city_idx: ci
      else
        # Update cache. No sense in incurring cost of object creation.
        cached.cable_len = cable_len
        cached.cable_len_cum = cached.cable_len_cum + cable_len
        cached.cable_len_cum %= 1_000_000_007 if cached.cable_len_cum >= 1_000_000_007
        cached.n = n
        cached.city_idx = ci
        cached.dup = dup if dup
      end
    }
    rbt.each do |pop, info|
      #p "#{pop}: #{info.inspect}"
      sum += pop * info.cable_len_cum
      sum %= 1_000_000_007 if sum >= 1_000_000_007
    end
    #puts "sum = #{sum}"
  end
  sum
end

T = gets.strip.to_i
puts "#{Time.now.to_f}: Starting!"
(0...T).each {|tc|
  # Read n, [dist1, ...], [pop1, ...]
  n, dists, pops = read_block
  # Create zipped list: [[dist1, pop1], ...]
  cities = dists.zip pops
  # Sort by distances.
  cities = cities.sort do |a, b|
    a[0] <=> b[0]
  end

  cable_dist = sum_cable_len cities
  puts "#{Time.now.to_f}: Finished test case #{tc}: # cities=#{n}"
  puts cable_dist % 1_000_000_007
}
puts "#{Time.now.to_f}: Finished!"


# vim:ts=2:sw=2:et:tw=120
