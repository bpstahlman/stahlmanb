# /bin/ruby

# Status: 50% of test cases "terminated with timeout". Input files were very large: 100000 strings, some of them longer
# than any word in English language.
# Important Note: Verified (by purchasing in/out files for 5 hackos) that my answer on the 1st timed out test case was
# correct - just took longer than the 10s allotted.
# TODO: Optimize sort. Possibly convert up front to array of codepoints to avoid the split. Could be that string
# processing, due to multibyte issues, is more costly...
# Idea: Instead of deferring swap, what if I used it to keep sorted as I go?
t = gets.to_i
(0...t).each do |tc|
  # catch block reads next string and returns processed output (possibly 'no answer')
  # Note: {} used in lieu of do...end for precedence reasons.
  puts catch(:foo) {
    w = gets.strip
    l = w.length
    # Outer loop works backwards from end to find swap point.
    for i in -2.downto -l
      # Find the swap point.
      if w[i] < w[i+1]
        # Sort substring beyond the swap point.
        w[i+1..-1] = w[i+1..-1].split('').sort.join('')
        # Find smallest val in sorted range that's larger than swap el and swap.
        (i+1..-1).each do |j|
          if w[i] < w[j]
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

