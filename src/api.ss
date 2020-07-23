;;;; api.ss

(define hamming (foreign-procedure "Shamming" (ptr ptr) ptr))
(define levenshtein (foreign-procedure "Slevenshtein" (ptr ptr) ptr))
(define norm-levenshtein (foreign-procedure "Snorm_levenshtein" (ptr ptr) ptr))
(define damerau-levenshtein (foreign-procedure "Sdamerau_levenshtein" (ptr ptr) ptr))
(define norm-damerau-levenshtein (foreign-procedure "Snorm_damerau_levenshtein" (ptr ptr) ptr))
(define jaro (foreign-procedure "Sjaro" (ptr ptr) ptr))
(define jaro-winkler (foreign-procedure "Sjaro_winkler" (ptr ptr) ptr))

(define string->set
  (lambda (str)
    (let ([ht (make-eqv-hashtable)]
          [len (string-length str)])
      (do ([i 0 (fx1+ i)])
          ((fx=? i len) ht)
        (let ([c (string-ref str i)])
          (if (hashtable-contains? ht c)
              (hashtable-update! ht c fx1+ #f)
              (hashtable-set! ht c 1)))))))

(define intersection-length
  (lambda (x y)
    (let ([res 0])
      (let-values ([(keys x-vals) (hashtable-entries x)])
        (vector-for-each (lambda (key x-val)
                           (let ([y-val (hashtable-ref y key #f)])
                             (when y-val
                               (set! res (fx+ res (fxmin x-val y-val))))))
                         keys x-vals))
      res)))

(define (union-length x y)
  (define temp (make-eqv-hashtable))
  (define res 0)

  (define (extract h)
    (let-values ([(keys vals) (hashtable-entries h)])
      (vector-for-each (lambda (key val)
                         (let ([t-val (hashtable-ref temp key #f)])
                           (hashtable-set! temp key
                                           (if t-val (fxmax val t-val) val))))
                       keys vals))
    h)

  (begin (extract x)
         (extract y)
         (vector-for-each (lambda (val) (set! res (fx+ res val)))
                          (hashtable-values temp))
         res))

(define overlap
  (lambda (str1 str2)
    (/ (intersection-length (string->set str1)
                            (string->set str2))
       (fxmin (string-length str1)
              (string-length str2)))))

(define jaccard
  (lambda (str1 str2)
    (let ([x (string->set str1)]
          [y (string->set str2)])
      (if (and (fxzero? (hashtable-size x))
               (fxzero? (hashtable-size y)))
          1
          (/ (intersection-length x y)
             (union-length x y))))))
