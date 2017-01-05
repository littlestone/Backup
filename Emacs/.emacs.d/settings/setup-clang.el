;;; setup-clang.el --- Emacs C Language Settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Automatic indentation
(electric-indent-mode +1)

;; Default indentation level for CC mode
(setq-default c-basic-offset 4)

;; Use gdb-many-windows by default
(setq gdb-many-windows t)

;; Non-nil means display source file containing the main routine at startup
(setq gdb-show-main t)

;; Disassemble C/C++ code under cursor in Emacs
(setq disaster-cc "gcc")
(define-key c-mode-base-map (kbd "C-c M-d") 'disaster)

;; Quickly switch between header and implementation
(setq ff-always-in-other-window t)
(add-hook 'c-mode-common-hook (lambda() (local-set-key (kbd "C-c M-o") 'ff-find-other-file)))

(provide 'setup-clang)
;;; setup-clang.el ends here
