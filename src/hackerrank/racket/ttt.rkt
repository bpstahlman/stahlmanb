(define board (list (list "1" "2" "3") (list "4" "5" "6") (list "7" "8" "9")))


(define (display_board board)
 (printf (string-join (map (lambda (lis) (string-join lis " | ")) board) "\n----------\n")))

(define joiner (curry (lambda (sep lis) (string-join lis sep))))
(define joiner (curryr string-join))
(define join-with-bar (curryr string-join "|"))
(join-with-bar '("foo" "bar" "baz"))
