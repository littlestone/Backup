;;; lars-defuns.el --- Lars Tveito's Emacs Lisp Functions -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(defun kill-this-buffer-unless-scratch ()
  "Works like `kill-this-buffer' unless the current buffer is the
*scratch* buffer. In witch case the buffer content is deleted and
the buffer is buried."
  (interactive)
  (if (not (string= (buffer-name) "*scratch*"))
      (kill-this-buffer)
    (delete-region (point-min) (point-max))
    (switch-to-buffer (other-buffer))
    (bury-buffer "*scratch*"))
  (force-mode-line-update))

(defun cycle-themes ()
  "Returns a function that lets you cycle your themes."
  (lexical-let ((themes '#1=(default-black monokai deep-blue . #1#)))
    (lambda ()
      (interactive)
      ;; Rotates the theme cycle and changes the current theme.
      (load-theme (car (setq themes (cdr themes))) t))))

(provide 'lars-defuns)
;;; lars-defuns.el ends here
