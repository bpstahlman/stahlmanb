#!/usr/bin/ruby
# Problem Statement
# 
# Given a list of N integers, your task is to select K integers from the list such that its unfairness is minimized.
# 
# if (x1,x2,x3,…,xk) are K numbers selected from the list N, the unfairness is defined as
# 
# max(x1,x2,…,xk)-min(x1,x2,…,xk)
# where max denotes the largest integer among the elements of K, and min denotes the smallest integer among the elements of K.
# 
# Input Format 
# The first line contains an integer N. 
# The second line contains an integer K. 
# N lines follow. Each line contains an integer that belongs to the list N.
# 
# Note: Integers in the list N may not be unique.
# 
# Output Format 
# An integer that denotes the minimum possible value of unfairness.
# 
# Constraints 
# 2<=N<=1E5 
# 2<=K<=N 
# 0 <= integer in N <= 1E9
# Code required to read in the values of k,n and candies.
def compute(n, k, candies)
    candies.sort!
    diff_min = nil
    (0..n-k).each do |i|
        diff = candies[i + k - 1] - candies[i]
        if diff_min.nil? || diff < diff_min
            diff_min = diff
        end
    end
    return diff_min
end
n = gets.to_i
k = gets.to_i
candies = Array.new(n)
(0...n).each do |i|
      candies[i] = gets.to_i
end
ans = compute n, k, candies
puts ans
# vim:ts=4:sw=4:et:tw=120
