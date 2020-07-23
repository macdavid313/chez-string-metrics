;;;; build.ss
(import (chezscheme))

(define cc (or (getenv "CC") "gcc"))
(define chez_kernel_path
  (or (getenv "CHEZSCHEME_KERNEL") (getenv "CHEZ_KERNEL")
      (errorf 'string-metrics-build "Cannot decide where is \"scheme.h\", please set the environment variable 'CHEZSCHEME_KERNEL' or 'CHEZ_KERNEL'")))

(case (machine-type)
  ((a6nt ta6nt) (errorf 'string-metrics-build "Sorry, it doesn't build on Windows yet."))
  (else
   (let ([cmd1 (string-append cc " -c -Wall -Werror -fpic -O3 -I" chez_kernel_path " c/string_metrics.c")]
         [cmd2 (string-append cc " -shared -o libstring_metrics.so string_metrics.o")])
     (display (format "Start building: ~a~%" cmd1))
     (system cmd1)
     (display (format "Start building: ~a~%" cmd2))
     (system cmd2))))

;;; compile whole library for distribution
(parameterize ([optimize-level 2]
               [generate-wpo-files #t]
               [generate-inspector-information #f])
  (compile-file "string-metrics.ss")
  (compile-whole-library "string-metrics.wpo" "string-metrics.so"))
