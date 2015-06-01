#! /usr/bin/ruby

t = gets.to_i
(0...t).each do |tc_idx|
    n = gets.to_i
    h = 1
    (0...n/2).each do |cycle_idx|
        h *= 2
        h += 1
    end
    # Handle any partial year.
    h *= 2 if n % 2 != 0
    puts h
end
