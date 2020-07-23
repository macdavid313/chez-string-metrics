;;;; string-metrics.ss
(library (string-metrics)
  (export hamming
          levenshtein norm-levenshtein
          damerau-levenshtein norm-damerau-levenshtein
          jaccard overlap
          jaro jaro-winkler)
  (import (chezscheme))

  (include "src/lib.ss")
  (include "src/api.ss")
  ) ;; end of library
