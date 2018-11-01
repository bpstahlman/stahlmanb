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

(define *show-graph* (make-parameter null))
(define *max-height* (make-parameter 20))
(define *num-heights* (make-parameter 20))
(define *heights* (make-parameter #f))
 
(command-line
   #:program "Fence area maximizer"
   #:once-each
   [("-m" "--max-height") mh
			  "Maximum slat height"
                       (*max-height* mh)]
   [("-n" "--num-heights") nh
			  "Desired # of slats in fence"
                       (*num-heights* nh)]
   [("-g" "--show-graph")
			  ("Show graph of output"
			   "defaults to ON for small values of --num-heights and --max-height")
                       (*show-graph* #t)]
   [("-G" "--hide-graph")
			  "Hide graph of output regardless of input sizes"
                       (*show-graph* #f)]
   [("-l" "--heights") hs
			  "List of heights to use"
			  ; TODO: Read the list...
                       (*heights* (map (compose round string->number) (string-split hs)))]
   #:args () #t)

; Default determined from inputs when neither --show-graph nor --hide-graph provided.
(when (null? (*show-graph*)) (*show-graph* (and (<= (*max-height*) 70) (<= (*num-heights*) 50))))

; Function to graph the slats horizontally
(define (horiz-graph heights)
  (printf "~a~n" (make-string (*max-height*) #\=))
  (for ([h heights])
    (printf "|~a (~a)~n" (make-string h #\*) h)))
  (printf "~a~n" (make-string (*max-height*) #\=))

; Driver program
(let* ([hts (take (*num-heights*) (randoms (*max-height*)))]
       [max-area (find-largest-rec (*heights*))])
  (printf "Heights: ~a~n" (sequence->list (*heights*)))
  ;(printf "~a~n" (build-string (*max-height*) (lambda (i) (integer->char (+ (char->integer #\0) (modulo i 10))))))
  (when (*show-graph*) (horiz-graph (*heights*)))
  (printf "Max area: ~a~n" max-area))

