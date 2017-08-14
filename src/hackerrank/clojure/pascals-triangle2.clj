; For a given integer K, print the first K rows of Pascal's Triangle.
; Print each row with each value separated by a single space. The value at the
; nth row and rth column of the triangle is equal to...
; n! / (r! * (n - r)!)
; ...where indexing starts from 0. These values are the binomial coefficients.

(require '[clojure.string :as s])

(defn pascal [k & {:keys [print-row] :or {print-row println}}]
  ; Compose special output function to be used for all rows.
  ; Also, pre-decrement k so that everything is 0-based.
  (let [pfn (comp print-row (partial s/join " ") reverse)
        k (dec k)
        ; Let input decide between machine integers and BigInt.
        [zero zero-fact] (if (instance? clojure.lang.BigInt k) [0N 1N] [0 1])]
    ; Process rows
    (loop [n zero n! zero-fact]
      ; Process row n
      (pfn ((fn [row r n-r r! n-r!]
              (let [row (cons (/ n! (* r! n-r!)) row) r+ (inc r)]
                (if (pos? n-r)
                  (recur row r+ (dec n-r)
                         (* r! r+)
                         (if (> n-r 1) (/ n-r! n-r) n-r))
                  row)))
              () zero n zero-fact n!))
      (if (< n k) (recur (inc n) (* n! (inc n)))))))

(Integer/parseInt (read-line))

(time (pascal 5))
(time (pascal 20))
; Note: Pass BigInt to prevent integer overflow on large factorials; also,
; supply a print-row function that simply evaluates and discards its arguments
; (to avoid timing terminal output).
(time (pascal 100N :print-row #(do %& (print "*"))))
(time (pascal 5000N :print-row #(do %&(print "*"))))
