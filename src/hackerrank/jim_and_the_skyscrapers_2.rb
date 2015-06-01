# /bin/ruby

# Initial approach timed out.
n = gets.to_i
hs = gets.strip.split(' ').map {|h| h.to_i}

count = 0
opt = {}
hs.each do |h|
  if !opt.has_key? h
    opt[h] = 1
  else
    count += 2 * opt[h]
    opt[h] += 1
  end
  opt.delete_if do |_h, _c|
    _h < h
  end
end
puts count

# vim:ts=2:sw=2:et:tw=120

