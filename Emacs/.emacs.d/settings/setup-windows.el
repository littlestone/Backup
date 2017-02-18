;;; setup-windows.el --- Emacs windows environment settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Make Emacs C source directory permanent and read-only by default
(setq find-function-C-source-directory "C:/GNU/bin/emacs/src")
(dir-locals-set-class-variables
 'emacs
 '((nil . ((buffer-read-only . t)
           (show-trailing-whitespace . nil)
           (tab-width . 8)
           (eval . (whitespace-mode -1))))))
(dir-locals-set-directory-class find-function-C-source-directory 'emacs)

;; Flycheck clang include path
(setq flycheck-clang-include-path (list "C:/cygwin/usr/include"))

;; Use aspell for spell checking: brew install aspell --lang=en
(setq ispell-program-name "C:/Program Files (x86)/Aspell/bin/aspell")

(provide 'setup-windows)
;;; setup-windows.el ends here
