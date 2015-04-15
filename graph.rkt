#!/usr/bin/env racket
#|
Copyright © 2015 Vibhav Pant <vibhavp@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the “Software”), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|#

#lang racket

(require racket/system)
(require racket/port)
(require racket/string)

(define output-file-name (open-output-file "out.dot" #:mode 'text))

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
  (fprintf output-file-name "digraph depgraph {\n")
  (for ([package package-list])
    (for ([dep (dep-list package)])
      (let ([index-of-> (index-of (string->list dep) #\>)])
        (fprintf output-file-name
                 "\"~a\" -> \"~a\";\n"
                 package (if index-of-> (substring dep 0 index-of->) dep)))))
  (fprintf output-file-name "}")
  (printf "Done!"))

(module* main #f
  (gen-graph))
