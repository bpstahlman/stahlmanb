#lang racket

(require (prefix-in dc: data/collection))
(require memoize)
(require anaphoric)

(define c_tl "\u250f") ; topleft
(define c_tc "\u2533") ; topcenter
(define c_tr "\u2513") ; topright
(define c_bl "\u2517") ; botleft
(define c_bc "\u253b") ; botcenter
(define c_br "\u251b") ; botright
(define c_cl "\u2523") ; centerleft
(define c_cr "\u252b") ; centerright
(define c_hz "\u2501") ; horizontal
(define c_vt "\u2503") ; vertical
(define c_cx "\u254b") ; cross
(define c_sp "\u0020") ; space

(struct square (chr attrs) #:transparent)
(define attr-names (hash
		     'red 31 'green 32 'yellow 33 'blue 34
		     'violet 35 'turquoise 36 'grey 37 'black 38
		     'bold 1 'faint 2 'reset 0 'italic 3 'underline 4
		     'reverse 7 'conceal 8 'crossed-out 9
		     'slow-blink 5 'fast-blink 6))
(define test-squares (hash
		      (cons 0 0) (square #\M '(red bold underline))
		      (cons 7 0) (square #\K '(red faint))
		      (cons 5 1) (square #\Q '(green bold fast-blink))
		      (cons 7 7) (square #\Z '(red bold crossed-out))
		      (cons 6 6) (square #\S '(blue bold underline))
		      (cons 1 3) (square #\G '(green faint))
		      (cons 4 4) (square #\J '(turquoise bold slow-blink))
		      (cons 3 5) (square #\A '(red bold))))

; Return struct square corresponding to row/col, else #f
(define (get-square sqrs row col)
  (hash-ref sqrs (cons row col) #f))


; Make generator function: returns function like gf0 and gfn, but for interior
; rows.
; Accepts char index within a row and returns the corresponding char as string.
(define (make-gf fst lst chrs ncols)
  (lambda (i)
    (let-values ([(col mi) (quotient/remainder i 4)])
      (cond [(= i 0) fst]
	    [(= i (sub1 ncols)) lst]
	    [else (vector-ref chrs mi)]))))

; Return display string corresponding to input square struct.
(define (get-square-str sqr)
  (let ([cstr (string (square-chr sqr))]
	[attrs (square-attrs sqr)])
    (if (empty? attrs)
	 cstr
	 (string-join (map (compose number->string (curry hash-ref attr-names)) attrs)
		      ";" #:before-first "\033["
		      #:after-last (string-append "m" cstr "\033[0m")))))

; Functions that take char index (multiple chars per checkerboard column) and
; return the corresponding character (as a string).
; Note: gf0 handles first row of chars, gfn the final row
(define gf0 (curry make-gf c_tl c_tr (vector c_tc c_hz c_hz c_hz)))
(define gfn (curry make-gf c_bl c_br (vector c_bc c_hz c_hz c_hz)))
(define (sgv mi) (if (= mi 0)
		  (curry make-gf c_cl c_cr (vector c_cx c_hz c_hz c_hz))
		  (curry make-gf c_vt c_vt (vector c_vt c_sp c_sp c_sp))))

; Build
(define (build-a-row ncols rfn [cfn #f])
  (for/fold ([str ""] #:result str)
    ([icol (range ncols)]
     [mi (dc:cycle (range 4))])
    (let ([col (quotient icol 4)])
      (string-append str
		     (or (and cfn (= mi 2)
			      (and-let [sqr (cfn col)] (get-square-str sqr)))
			 (rfn icol))))))

(define (make-board n sqrs)
  (let ([nrows (add1 (* n 2))]
	[ncols (add1 (* n 4))])
    (for/vector #:length nrows
      ([i (in-naturals)]
       #:when #t
       [j (range 2)])
      (build-a-row ncols (cond
			   [(= i j 0) (gf0 ncols)]
			   [(= i n) (gfn ncols)]
			   [else ((sgv j) ncols)])
		   (and (= j 1) (curry get-square sqrs i))))))


(printf "~n")
(for ([row (make-board 8 test-squares)])
  (printf "~a~n" row))

