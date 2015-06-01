#!/bin/ruby

require 'set'

def lonelyinteger(a) 
  s = a.inject Set.new do |s, i|
    s.delete? i or s << i
  end
  s.first
end
a = gets.strip.to_i
b = gets.strip.split(" ").map! {|i| i.to_i}
print lonelyinteger(b)

# vim:ts=2:sw=2:et:tw=120
