 ;;; sai-defuns.el --- My elisp defuns -*- lexical-binding: t; -*-

;;; Commentary:

;; My Emacs Lisp Functions

;;; Code:

(defun sai/insert-date ()
  "Insert curent date and time."
  (interactive)
  (insert (format-time-string "%Y/%m/%d %H:%M:%S" (current-time))))

(defun sai/toggle-elisp-debugger ()
  "Turn Emacs Lisp debugger on/off."
  (interactive)
  (if (eq debug-on-error t)
      (setq debug-on-error nil)
    (setq debug-on-error t))
  (message (if debug-on-error "Elisp debugger on" "Elisp debugger off")))

(provide 'sai-defuns)
;;; sai-defuns.el ends here
