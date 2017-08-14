(defn prefix-compress [x y]
  (doseq [s
          ; Build sequence: p x' y'
          (loop [p () [x & xs :as xxs] x [y & ys :as yys] y]
            (if (or (empty? xs) (empty? ys) (not (= x y)))
              [(clojure.core/reverse p) xxs yys]
              (recur (cons x p) xs ys)))]
    (println (count s) " " (clojure.string/join s))))

(prefix-compress "foobar" "foobaz")
(prefix-compress "foolysoo" "forama")
(prefix-compress "goolysoo" "forama")
