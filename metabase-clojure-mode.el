;;; metabase-clojure-mode.el --- Minor mode with extra Clojure code editing functions -*- coding: utf-8; -*-

;; Author: Cam Saül <cammsaul@gmail.com>
;; Maintainer: Cam Saül <cammsaul@gmail.com>
;; URL: https://github.com/camsaul/metabase-clojure-mode
;; Created: 6th June 2017
;; Version: 1.0
;; Keywords: clojure, metabase
;; Package-Requires: ((emacs "24.4"))

;;; Commentary:

;; Metabase Clojure Mode provides a few commands that make writing Clojure
;; code a bit quicker and easier.  By default, these functions are bound
;; to keys under the prefix C-c m; see documentation for various functions
;; for more details.
;;
;; Provided commands:
;;
;; `mbclj-insert-println'
;; `mbclj-insert-header'
;;
;; Enabling `metabase-clojure-mode' is simple:
;;
;;     (add-hook 'clojure-mode-hook #'metabase-clojure-mode)

;;; Code:

(require 'cl-lib)


;;; ------------------------------------------------------------ Inserting Debugging Statements ------------------------------------------------------------

;;;###autoload
(defun mbclj-insert-println (text)
  "Insert a println statement to print the value of TEXT for debugging purposes.
TEXT is presumably some form or variable that can be successfully evaluated where
inserted.  Alternatively, calling this function with a prefix arg will generate a println
statement that will *not* evaluate its arg; this is useful for more generic
debugging printlns.

Calling normally w/ input \"value\":

    (println \"value:\" value) ; NOCOMMIT

Calling with prefix arg w/ input \"value\":

    (println \"value\") ; NOCOMMIT"
  (interactive "sprintln: ")
  (if current-prefix-arg
      (insert "(println \"" text "\") ; NOCOMMIT")
    (insert "(println \"" text ":\" " text ") ; NOCOMMIT")))

;;; ------------------------------------------------------------ Inserting Code Headers ------------------------------------------------------------

;;;###autoload
(defun mbclj-insert-header (text)
  "Insert a formatted header comment containing TEXT.
This is useful for breaking up massive namespaces into smaller sections.
With a prefix arg, you may optionally specify the width of the header as well."
  (interactive "sheader text: ")
  ;; calculate the number of spaces that should go on either side of the text
  (let* ((total-width (if current-prefix-arg
                          (let ((input (read-from-minibuffer "total width [120]: ")))
                            (if (zerop (length input))
                                120
                              (string-to-number input)))
                        120))
         (padding (/ (- total-width (length text)) 2))
         (horizonal-border (concat ";;; +"
                                   (make-string total-width ?-)
                                   "+\n"))
         (text-padding (make-string padding ? )))
    (insert
     (concat
      ;; top row
      horizonal-border
      ;; middle row
      ";;; |"
      text-padding
      text
      text-padding
      ;; if total-width and text aren't BOTH odd or BOTH even we'll have one less space than needed so add an extra so things line up
      (unless (eq (cl-oddp (length text))
                  (cl-oddp total-width))
        " ")
      "|\n"
      ;; bottom row
      horizonal-border))))


;;; ------------------------------------------------------------ Minor Mode ------------------------------------------------------------

;; TODO - Make the prefix key configuable a la clojure-refactor-mode

(defvar mbclj--keymap
  '(("C-c m p" . mbclj-insert-println)
    ("C-c m h" . mbclj-insert-header)))

(defvar metabase-clojure-mode-map
  (let ((map (make-sparse-keymap)))
    (dolist (key->f mbclj--keymap)
      (define-key map (kbd (car key->f)) (cdr key->f)))
    map))


;;;###autoload
(define-minor-mode metabase-clojure-mode
  "Toggle Metabase Clojure Mode.
Metabase Clojure mode provides several useful functions for writing Clojure code in Emacs, like \\[mbclj-align-map] and \\[mbclj-insert-header].
These various functions are bound to various keys using the 'C-c m' prefix."
  :lighter " MBClj"
  :keymap metabase-clojure-mode-map)


(provide 'metabase-clojure-mode)
;;; metabase-clojure-mode.el ends here
