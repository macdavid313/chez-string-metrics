;;;; build.ss
(import (chezscheme))

(define cc (or (getenv "CC") "gcc"))
(define chez_lib_path
  (or (getenv "CHEZSCHEME_KERNEL") (getenv "CHEZ_KERNEL")
      (errorf 'string-metrics-build "Cannot decide where is \"scheme.h\", please set the environment variable 'CHEZSCHEME_KERNEL' or 'CHEZ_KERNEL'")))

(case (machine-type)
  ((a6nt ta6nt) (errorf 'string-metrics-build "Sorry, it doesn't build on Windows yet."))
  (else (system (string-append cc " -c -Wall -Werror -fpic -O3 -I" chez_lib_path " c" (string (directory-separator)) "string_metrics.c"))
        (system (string-append cc " -shared -o libstring_metrics.so string_metrics.o"))))

;;; compile whole library for distribution
(parameterize ([optimize-level 2]
               [generate-wpo-files #t]
               [generate-inspector-information #f])
  (compile-file "string-metrics.ss")
  (compile-whole-library "string-metrics.wpo" "string-metrics.so"))
