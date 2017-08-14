; prow - previous row of ranges
; cmap - map of [i j] to count
; row  - current grid row:
; c    - cell value
; rs   - ranges for current row: [[si ei [i j]]...]
; r    - current range (not yet added to rs)
(defn get-max [grid]
  (loop [[[si ei [pi pj] :as prng] & prngs :as prow] []
         cmap {}
         [row & rows] grid
         [c & cs] row
         i 0 j 0
         rs []
         r nil])
  (if-not row
    cmap
    (if-not c
      ; Finished row
      (recur rs rows (if (next rows) (first (rest rows)) []) (inc i) 0 [] nil)
      (if (= 1 c)
        (if-not r
          ; New range
          (if-not prng
            (recur [] (assoc cmap [i j] 1))
            (if (<= (dec si) j)
              (recur (if (> j (inc ei)) prngs prow) (assoc cmap [i j] 1) grid []))

            ))))))

(def grid [[0 0 1 0 1 1 0 1 1 0]
           [1 0 0 1 1 0 1 0 1 0]
           [0 1 0 0 1 1 0 1 1 0]
           [1 0 0 1 1 0 0 1 0 0]])
(def grid2 [[1 0 1 0 1 1 0 1 1 0]
            [1 0 1 0 1 0 0 0 1 0]
            [1 0 0 1 0 0 1 0 1 0]
            [0 1 0 0 0 1 0 1 1 0]
            [1 0 1 1 1 0 0 0 0 0]])
;; Note: At 3,7 the group containing 2,6 needs to be joined, but it's already passed off prngs, which means problem occurs when we get to 4,4 where the 2 big groups should be connected.
;; Idea: Function for updating the ij of the disconnecting group (or rather the rng(s) it's connected to?)
;; Alternate Idea: Build chains instead of maintaining the count.

(defn do-row [cells prngs i cmap]
  (loop [cmap cmap
         [[psi pei pij] & prngs :as prngss] prngs
         [csi cei cij :as rng] nil
         rngs []
         [c & cs :as css] cells
         j 0]
    (if-not c
      ; Done with row
      {:rngs (if rng (conj rngs rng) rngs) :cmap cmap}
      ; Cells remaining in row
      (do
        (if (= c 1)
          (let [
                ; leaving range from previous row?
                disconnecting (and pei (< pei j))
                ; at start of range?
                ; Note: Can get here twice for same position.
                head (or (not csi) (= csi j))
                ; entering range from previous row?
                ; Note: If also disconnecting, we'll handle connecting next time.
                connecting (and (not disconnecting)
                                psi
                                (if head (<= (dec psi) j (inc pei)) (= j (dec psi))))]
            (do
              (prn "-- Before binding --")
              (prn "i=" i " j=" j " conn=" connecting " disc" disconnecting)
              (prn "[psi pei pij]=" [psi pei pij] " [csi cei cij]=" rng)
              (prn "rng=" rng)
              (prn "prngss=" prngss)
              (prn "cmap=" cmap)
              (prn)
              (let [swap-ij (and connecting (pos? (compare pij cij)))
                    ; Rebind...
                    rng' (if rng
                           ; Existing range
                           (if connecting
                             ; Take earliest ij
                             [csi j (if swap-ij cij pij)]
                             ; Update only cei
                             (assoc rng 1 j))
                           ; Starting new range
                           [j j (if (or disconnecting connecting) pij [i j])])
                    ij' (rng' 2)
                    cmap' (if disconnecting
                            cmap ; Never update count on disconnect.
                            ; Always add 1, but additionally, if connecting to a
                            ; previous range, we'll need to add either its count,
                            ; or if its ij is better, the current range's count.
                            (assoc cmap ij'
                                   (+ (get cmap ij' 0)
                                      1
                                      ; Bug: May need to add something for connecting even for head of range (i.e., !rng)!
                                      ; Bug!: Currently, double-counting can occur when same block is connected to more than once by discontiguous rngs on current row!
                                      ; Solution: Treat cij == pij specially...
                                      (if (and rng connecting (not (= cij pij)))
                                        (do (prn "Getting key " (if (= ij' cij) pij cij) " from cmap") (get cmap (if (= ij' cij) pij cij) 0))
                                        0))))
                    [[psi pei pij] & _ :as prngs']
                    (if disconnecting prngs (if swap-ij (conj prngs [psi pei ij']) prngss))
                    cs' (if disconnecting css cs)
                    j' (if disconnecting j (inc j))]
                (prn "-- After binding --")
                (prn "[psi pei pij]=" [psi pei pij] " [csi cei cij]=" rng)
                (prn "ij'=" ij' " swap-ij=" swap-ij)
                (prn " rng'=" rng')
                (prn "prngs'=" prngs')
                (prn "cmap'=" cmap')
                (prn)
                (recur cmap' prngs' rng' rngs cs' j'))))
          ; c == 0
          (recur cmap (if (and pei (< pei j)) prngs prngss) nil (if rng (conj rngs rng) rngs) cs (inc j)))))))


(defn do-grid [grid]
  (loop [[row & rows :as rowss] grid prngs [] cmap {} i 0]
    (let [{:keys [rngs cmap]}
          (do-row row prngs i cmap)]
      (if (seq rows) (recur rows rngs cmap (inc i)) cmap))))

(defn connected-cell-count [grid]
  (apply max (vals (do-grid grid))))
(do-row (grid 0) [] 0 {})
(get-max grid)
