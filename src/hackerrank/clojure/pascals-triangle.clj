; For a given integer K, print the first K rows of Pascal's Triangle.
; Print each row with each value separated by a single space. The value at the
; nth row and rth column of the triangle is equal to...
; n! / (r! * (n - r)!)
; ...where indexing starts from 0. These values are the binomial coefficients.

(require '[clojure.string :as s])

(defn pascal [k]
  ; Process rows
  (loop [n 0 n! 1]
    ; Process row n
    ; Avoid calculating factorials for each column.
    ; Note: The n-r! terms are the reverse of the n! terms.
    (let [r!s (reduce
                #(cons (if (empty? %1) 1 (* (first %1) %2)) %1)
                () (range (inc n)))
          n-r!s (reverse r!s)
          ; Compose function for printing the reversed and joined list of
          ; numbers.
          pfn (comp println (partial s/join " ") reverse)]
      ; Use recursive lambda to reduce the pre-calculated lists of factorial
      ; terms.
      ; Note: Could also use reduce, but then we'd need to zip the 2 sequences
      ; together.
      (pfn ((fn [row [r! & r!s] [n-r! & n-r!s]]
              (let [row (cons (/ n! (* r! n-r!)) row)]
                (if (empty? r!s) row (recur row r!s n-r!s))))
              () r!s n-r!s)))
    (if (< n (dec k)) (recur (inc n) (* n! (inc n))))))

(pascal 5)
(pascal 20)
