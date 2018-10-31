#lang racket

(require data/collection)
(require memoize)

(define c_tl #\u250f) ; topleft
(define c_tc #\u2533) ; topcenter
(define c_tr #\u2513) ; topright
(define c_bl #\u2517) ; botleft
(define c_bc #\u253b) ; botcenter
(define c_br #\u251b) ; botright
(define c_cl #\u2523) ; centerleft
(define c_cr #\u252b) ; centerright
(define c_hz #\u2501) ; horizontal
(define c_vt #\u2503) ; vertical
(define c_cx #\u254b) ; cross
(define c_sp #\u0020) ; space

(define (sgf fst lst chrs ncols)
  (lambda (i)
    (let-values ([(col mi) (quotient/remainder i 4)])
      (cond [(= i 0) fst]
	    [(= i (sub1 ncols)) lst]
	    [else (vector-ref chrs mi)]))))


(define gf0 (curry sgf c_tl c_tr (vector c_tc c_hz c_hz c_hz)))
(define gfn (curry sgf c_bl c_br (vector c_bc c_hz c_hz c_hz)))
(define (sgv i) (if (= i 0)
		  (curry sgf c_cl c_cr (vector c_cx c_hz c_hz c_hz))
		  (curry sgf c_vt c_vt (vector c_vt c_sp c_sp c_sp))))

(define (make-board n pcs)
  (let ([rows (add1 (* n 2))]
	[cols (add1 (* n 4))])
    (for/vector #:length rows
      ([i (in-naturals)]
       #:when #t
       [j (range 2)])
      (build-string cols (cond
			   [(= i j 0) (gf0 cols)]
			   [(= i n) (gfn cols)]
			   [else ((sgv j) cols)])))))


(printf "~n")
(for ([row (make-board 8 '())])
  (printf "~a~n" row))

