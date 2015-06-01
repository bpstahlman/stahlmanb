# /bin/ruby

# Note: This is a rewrite of bigger_is_greater_orig.rb, which worked, but timed out on large test cases.
t = gets.to_i
(0...t).each do |tc|
  # catch block reads next string and returns processed output (possibly 'no answer')
  # Note: {} used in lieu of do...end for precedence reasons.
  puts catch(:foo) {
    w = gets.strip
    l = w.length
    # Outer loop works backwards from end to find swap point: i.e., point at which char value first decreases (w.r.t.
    # subsequent (later) char in string).
    (-2.downto -l).each do |i|
      if w[i] < w[i+1]
        # Found swap point. Sort substring beyond it.
        w[i+1..-1] = w[i+1..-1].split('').sort.join('')
        # Find smallest val in sorted range that's larger than swap el.
        (i+1..-1).each do |j|
          if w[i] < w[j]
            # Swap and return.
            w[i], w[j] = w[j], w[i]
            throw :foo, w
          end
        end
      end
    end
    'no answer'
  }
end

# vim:ts=2:sw=2:et:tw=120

