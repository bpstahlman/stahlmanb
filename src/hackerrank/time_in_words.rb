#!/usr/bin/ruby
# Task
# Given the time in numerals we may convert it into words, as shown below:
# 
# 5:00 -> five o'clock
# 5:01 -> one minute past five
# 5:10 -> ten minutes past five
# 5:30 -> half past five
# 5:40 -> twenty minutes to six
# 5:45 -> quarter to six
# 5:47 -> thirteen minutes to six
# 5:28 -> twenty eight minutes past five

# Task: 
# Write a program which prints the time in words for the input given in the format mentioned above.
# 
# Input Format
# 
# There will be two lines of input:
# H, representing the hours
# M, representing the minutes
# 
# Constraints
# 1<=H<=12
# 0<=M<60
# Output Format
# 
# Display the time in words.

# Facilitate converting numbers in 0..29 to corresponding textual representation
$nums = %w(
    zero one two three four five six seven eight nine ten eleven twelve
    thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty
)
(1..9).each do |i|
    $nums << "twenty #{$nums[i]}"
end
def next_hour(h); h == 12 ? 1 : h + 1; end

def fmt_time(h, m)
    if m == 0
        "#{$nums[h]} o' clock"
    elsif m == 15
        "quarter past #{$nums[h]}"
    elsif m == 30
        "half past #{$nums[h]}"
    elsif m == 45
        "quarter to #{$nums[next_hour h]}"
    elsif m < 30
        "#{$nums[m]} minute#{m > 1 ? "s" : ""} past #{$nums[h]}"
    else
        m_to = 60 - m
        "#{$nums[m_to]} minute#{m_to > 1 ? "s" : ""} to #{$nums[next_hour h]}"
    end
end
h = gets.to_i
m = gets.to_i
puts fmt_time(h, m)


# vim:ts=4:sw=4:et:tw=120
