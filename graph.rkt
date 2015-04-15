#!/usr/bin/env racket

#lang racket

(require racket/system)
(require racket/port)
(require racket/string)

(define package-list (string-split
                      (with-output-to-string
                        (lambda ()
                          (system
                           "pacman -Ssq | tr '\\n' ' ' ")))))

(define (index-of l x)
  (for/or ([y l] [i (in-naturals)] #:when (equal? x y)) i))

(define (dep-list package)
  (let ([command (string-append
                   (string-append "pacman -Si " package)
                   "|grep \"Depends On\"")])
    (string-split (substring (with-output-to-string
                             (lambda () (system command))) 17))))

(define (gen-graph)
  (printf "digraph depgraph {\n")
  (for ([package package-list])
    (for ([dep (dep-list package)])
      (let ([index-of-> (index-of (string->list dep) #\>)])
        (fprintf (current-output-port)
                 "\"~a\" -> \"~a\";\n"
                 package (if index-of-> (substring dep 0 index-of->) dep)))))
  (print "}"))

(module* main #f
  (gen-graph))
