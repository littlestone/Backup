;;; setup-windows.el --- Emacs windows environment settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Make Emacs C source directory permanent
(setq find-function-C-source-directory "C:/GNU/bin/emacs/src")

;; Flycheck clang include path
(setq flycheck-clang-include-path (list "C:/cygwin/usr/include"))

;; Use aspell for spell checking: brew install aspell --lang=en
(setq ispell-program-name "C:/Program Files (x86)/Aspell/bin/aspell")

(provide 'setup-windows)
;;; setup-windows.el ends here
