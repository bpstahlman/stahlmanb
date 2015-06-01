# /bin/ruby

# Approach #2 timed out on degenerate case: large number monotonically decreasing down to 1, then monotonically
# increasing to large number.
# Note: This one was accepted on 18May2015.
n = gets.to_i
hs = gets.strip.split(' ').map {|h| h.to_i}

count = 0
hmap = Hash.new 0
# Vars used to skip unnecessary delete_if's.
# Min height in map
hmap_min = nil
# Height governing a queued delete
h_qdel = nil
# Loop starts at 2nd height (simplifies deferring logic till h prev is known).
(1...n).each do |i|
  h, h_prev = hs[i], hs[i-1]
  # Direction: -1=falling, 0=steady, 1=rising
  dir = h > h_prev ? 1 : h < h_prev ? -1 : 0

  if dir < 1
    # Not rising: check for deferred delete.
    # Note: For efficiency's sake, delete_if's deferred till after monotonic increase.
    if h_qdel
      # Calculate new low-water mark (nil if hash is emptied) in delete block.
      hmap_min = nil
      hmap.delete_if do |_h, _c|
        if _h < h_qdel
          true
        elsif hmap_min.nil? || _h < hmap_min
          # Keeping this one and it's new min.
          hmap_min = _h
          false
        end
      end
      h_qdel = nil
    end
  end

  if dir <= 0
    # Falling or steady
    hmap_min = h_prev if hmap_min.nil? || h_prev < hmap_min
    # Note: Relying on default value
    hmap[h_prev] += 2
  end

  if dir >= 0
    # Steady or rising
    # Note: Relying on default value
    count += hmap[h]
  end

  if dir == 1 && !hmap_min.nil? && h > hmap_min
    # Rising, and current h invalidates at least 1 height in hash.
    h_qdel = h
  end
  h
end
puts count

# vim:ts=2:sw=2:et:tw=120

