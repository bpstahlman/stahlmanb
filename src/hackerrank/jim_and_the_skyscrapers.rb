# /bin/ruby

n = gets.to_i
hs = gets.strip.split(' ').map {|h| h.to_i}
count = 0
(0...n).each do |i|
  hi = hs[i]
  # Find rightward paths beginning at i.
  hs[i+1...n].each do |hj|
    if hi == hj
      count += 2
    elsif hj > hi
      # No more rightward paths beginning at i
      break
    end
  end
end
puts count

# vim:ts=2:sw=2:et:tw=120

