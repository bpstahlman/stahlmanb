; Compute the Perimeter of a Polygon
(defn perimeter [[[x0 y0] :as pts]]
  (first
    (reduce (fn [[sum [xp yp]] [x y]]
              [(+ sum (Math/sqrt
                        (let [xd (- xp x) yd (- yp y)]
                          (+ (* xd xd) (* yd yd)))))
               [x y]])
            [0.0 [x0 y0]] (reverse pts))))

; Test Case
(let [pts [[-1 1] [1 1] [1 -1] [-1 -1]]]
  (perimeter pts))


