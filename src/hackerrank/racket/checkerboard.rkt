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
		       (cons 0 0)   (square #\M '(red bold underline))
		       (cons 7 0)   (square #\K '(red faint))
		       (cons 5 1)   (square #\Q '(green bold fast-blink))
		       (cons 7 7)   (square #\Z '(red bold crossed-out))
		       (cons 6 6)   (square #\S '(blue bold underline))
		       (cons 1 3)   (square #\G '(green faint))
		       (cons 4 4)   (square #\J '(turquoise bold slow-blink))
		       (cons 3 5)   (square #\A '(red bold))
		       (cons 11 4)  (square #\S '(blue bold underline))
		       (cons 9 3)   (square #\G '(green crossed-out underline))
		       (cons 3 11)  (square #\J '(turquoise bold slow-blink))
		       (cons 4 8)   (square #\A '(blue bold))
		       (cons 11 11) (square #\A '(violet bold underline italic))))

; Return struct square corresponding to row/col, else #f
(define (get-square sqrs row col)
  (hash-ref sqrs (cons row col) #f))

; Return display string corresponding to input square struct.
(define (get-square-str sqr)
  (let ([cstr (string (square-chr sqr))]
	[attrs (square-attrs sqr)])
    (if (empty? attrs)
      cstr
      (string-join (map (compose number->string (curry hash-ref attr-names)) attrs)
		   ";" #:before-first "\033["
		   #:after-last (string-append "m" cstr "\033[0m")))))

; Make generator function: e.g., a function like gf0 and gfn, but for interior
; rows.
; fst:  board drawing char used for char col idx 0
; lst:  board drawing char used for char col idx ncols-1
; chrs: vector of board drawing chars indexed by char col idx modulo 4
(define (make-gf fst lst chrs ncols)
  ; Accepts char index within a row and returns the corresponding char as string.
  (lambda (i)
    (let-values ([(col mi) (quotient/remainder i 4)])
      (cond [(= i 0) fst]
	    [(= i (sub1 ncols)) lst]
	    [else (vector-ref chrs mi)]))))

; Functions that take char index (multiple chars per checkerboard column) and
; return the corresponding character (as a string).
; Note: gf0 handles first row of chars, gfn the final row, and the functions
; returned by sgv handle everything else.
(define gf0 (curry make-gf c_tl c_tr (vector c_tc c_hz c_hz c_hz)))
(define gfn (curry make-gf c_bl c_br (vector c_bc c_hz c_hz c_hz)))
; Memoize this since I call it over and over.
(define/memo (sgv mi)
	     (if (= mi 0)
	       (curry make-gf c_cl c_cr (vector c_cx c_hz c_hz c_hz))
	       (curry make-gf c_vt c_vt (vector c_vt c_sp c_sp c_sp))))

; Build a single row of characters, returning the corresponding string.
; ncols:
;   # of character cols in the row
; rfn:
;   row function, accepts char col index and returns corresponding board
;   drawing char (as string)
; cfn: (optional)
;   cell function, accepts board col index and returns corresponding square
;   struct (#f if nothing in the square).
(define (build-a-row ncols rfn [cfn #f])
  (for/fold ([str ""] #:result str)
    ([icol (range ncols)]
     [mcol (dc:cycle (range 4))])
    (let ([col (quotient icol 4)])
      (string-append str
		     (or (and cfn (= mcol 2)
			      (and-let [sqr (cfn col)] (get-square-str sqr)))
			 (rfn icol))))))

; Build stream of strings representing a checkerboard of size n with square
; contents determined by the input hash of square structs, which maps pairs of
; row/col to the corresponding square struct.
; Note: Initially, returned vector of strings, but if caller is simply
; iterating, a stream is probably better, as it obviates need to select a
; concrete sequence type.
(define (make-board n sqrs)
  (let ([nrows (add1 (* n 2))]  ; # of char rows
	[ncols (add1 (* n 4))]) ; # of char cols
    (for/stream
      ([row (in-naturals)] ; board idx
       #:when #t
       [mrow (range 2)]    ; char idx modulo 2
       #:final (and (= row n) (= mrow 0)))
      (build-a-row ncols (cond
			   [(= row mrow 0) (gf0 ncols)] ; first char row
			   [(= row n) (gfn ncols)]      ; last char row
			   [else ((sgv mrow) ncols)])
		   (and (= mrow 1) (curry get-square sqrs row))))))


(printf "~n")
(for ([row (make-board 12 test-squares)])
  (printf "~a~n" row))

