; HackerRank Problem: Rotate String (abhiranjan)
; Display all n rotations of string.

; Example:
; String: abc
; Rotations: bca cab abc

(ns user (:require [clojure.string :as str]))

; Theoretical efficiency: O(N^2)
; Inner-most lambda (fn rot) is NOT tail-recursive.
; Should not be used for very long strings.
(defn rotate-string [[x & xs :as s]]
  (if (empty? xs)
    s
    (map str/join
         (reverse
           ; Note: This loop terminates before the final element (since it's
           ; cons'ed unchanged)
           (cons s (loop [ret () [x & xs] s [_ _ & ys] s]
                     (let [lst ((fn rot [x [y & ys]]
                                  (cons y (if (empty? ys)
                                            (list x)
                                            (rot x ys))))
                                  x xs)
                           ret (cons lst ret)]
                       (if (empty? ys) ret (recur ret lst ys)))))))))

; Theoretical efficiency: O(2N^2)
; Properly tail-recursive
; This approach is properly tail-recursive but O(2N^2)
(defn rotate-string-tco [[x & xs :as s]]
  (if (empty? xs)
    s
    (map str/join
         (reverse
           (cons s (loop [ret () [x & xs] s [_ & ys] s]
                     (let [lst (into (list x) (reverse xs))
                           ret (cons lst ret)]
                       (if (empty? (rest ys)) ret (recur ret lst ys)))))))))

; Test Results: For the longest string successfully rotated (5000 characters),
; the non-tco version completed in around 25% of the time required for the
; non-tco version. However, the non-tco version overflowed the stack for a 10K
; character string. The performance gains on shorter strings were less
; significant.
(for [cnt [1 5 10 100 500 1000 5000]]
  (let [s  (repeat cnt \a)]
    (print "-- cnt=" (str cnt) " --\n" )
    (print "Non-TCO: ")
    (time (rotate-string s))
    (print "TCO:     ")
    (time (rotate-string-tco s))
    nil))

(rotate-string "abcdef")
