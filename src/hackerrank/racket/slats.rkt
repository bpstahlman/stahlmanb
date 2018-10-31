#lang racket
; Figure out the ftree paths here...
(require ftree/ftree/ftree)
(require ftree/orderedseq/orderedseq)
(require racket/match)
(require data/collection)

; Slat contains an index and height
(struct slat (i h))

; Comparator function to sort slats by height
(define (cmp-slats a b)
  (< (slat-h a) (slat-h b)))

; Return: [max-area open-rectangles-ordered-set]
(define (process-slat os ph i h ma)
  (cond
    [(> h ph) ; open rectangles
     [vector ma (os-insert (slat i h) os)]]
    [(= h ph) ; nop
     (vector ma os)]
    [else     ; close rectangles
      (let*-values ([(os-o os-c) (os-partition (slat i (add1 h)) os)]
		    [(ma i-low)
		     (let loop ([ma ma] [i-low #f] [os-c os-c])
		       (if (ft-empty? os-c)
			 (values ma i-low)
			 (let-values ([(ma i-low)
				       (match (ft-hdL os-c)
					 [(struct slat (ii hh))
					  (let ([a (* (- i ii) hh)])
					    (values (if (> a ma) a ma)
						    (if (or (not i-low) (< ii i-low)) ii i-low)))])])
			   (loop ma i-low (ft-tlL os-c)))))])
	(vector
	  ma
	  ; Discard the closed ordered-set, which has now been full processed.
	  ; No! Can't discard the whole thing - need to transform to
	  ; something shorter...
	  ; Don't insert unconditionally! May already been one of this
	  ; height in os-o, and if there is, it's index must be <= this one's.
	  (if (and i-low (or (os-empty? os-o)
			     (< (slat-h (os-top os-o)) h)))
	    (os-insert (slat i-low h) os-o)
	    os-o)))]))

; Find largest rectangle in input sequence of slat heights.
(define (find-largest-rec heights)
  (let loop ([i 0] [pi -1] [ph -1] [heights heights] [ma 0] [os (mk-oseq cmp-slats)])
    (let ([h (if (empty? heights) -1 (first heights))])
      (match (process-slat os ph i h ma)
	[(vector ma os)
	 ; Extra debug info
	 ;(printf "i=~a ma=~a~n" i ma)
	 (if (negative? h) ma (loop (add1 i) i h (rest heights) ma os))]))))

; Function to graph the slats horizontally
(define (horiz-graph heights)
  (for ([h heights])
    (printf "|~a (~a)~n" (make-string h #\*) h)))

; Driver program
; TODO: These should probably be optional params
(define N 10)
(define MAX-H 20)
; TODO: Do I need to convert seq to list, or can I use seq functions in lieu of car?
(let* ([heights (take N (randoms MAX-H))]
       [max-area (find-largest-rec heights)])
  (printf "Heights: ~a~n" (sequence->list heights))
  (printf "~a~n" (make-string MAX-H #\=))
  ;(printf "~a~n" (build-string MAX-H (lambda (i) (integer->char (+ (char->integer #\0) (modulo i 10))))))
  (horiz-graph heights)
  (printf "~a~n" (make-string MAX-H #\=))
  (printf "Max area: ~a~n" max-area))

