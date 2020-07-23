(define libstring_metrics
  (case (machine-type)
    ((a6nt ta6nt) "libstring_metrics.dll")
    ((a6le i3le ta6le ti3le) "libstring_metrics.so")
    ((a6osx i3osx ta6osx ti3osx) "libstring_metrics.dylib")
    (else "libstring_metrics.so")))

(define (append-filename fn1 fn2)
  (let ([last-char (string-ref fn1 (fx1- (string-length fn1)))])
    (if (directory-separator? last-char)
        (string-append fn1 fn2)
        (string-append fn1 (string (directory-separator)) fn2))))

(define (search-lib)
  (call/1cc
   (lambda (return)
     (for-each (lambda (dir)
                 (for-each (lambda (fn)
                             (when (string=? fn libstring_metrics)
                               (return (append-filename dir fn))))
                           (directory-list dir)))
               (map car (library-directories)))
     (return #f))))

(define (load-libstring_metrics*)
  (let ([found? (search-lib)])
    (if found?
        (load-shared-object found?)
        (warningf 'load-libstring_metrics "~s (required by ~a) has not been loaded." libstring_metrics 'string-metrics))))

(define load-libstring_metrics
  (eval-when (compile load eval)
             (call/cc
              (lambda (k)
                (with-exception-handler
                    (lambda (x)
                      (when (condition? x)
                        (k (load-libstring_metrics*))))
                  (lambda () (load-shared-object libstring_metrics)))))))
