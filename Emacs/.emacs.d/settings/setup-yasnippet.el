﻿;;; setup-yasnippet.el --- A template system for Emacs -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'yasnippet)

;; Use only own snippets, do not use bundled ones
(defvar --yas-snippet-dir (expand-file-name "snippets" user-emacs-directory))
(when (not (file-exists-p --yas-snippet-dir))
  (make-directory --yas-snippet-dir))
(yas-global-mode 1)

;; Jump to end of snippet definition
(define-key yas-keymap (kbd "<return>") 'yas-exit-all-snippets)

;; Inter-field navigation
(defun yas/goto-end-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas--snippets-at-point)))
         (position (yas--field-end (yas--snippet-active-field snippet))))
    (if (= (point) position)
        (move-end-of-line 1)
      (goto-char position))))

(defun yas/goto-start-of-active-field ()
  (interactive)
  (let* ((snippet (car (yas--snippets-at-point)))
         (position (yas--field-start (yas--snippet-active-field snippet))))
    (if (= (point) position)
        (move-beginning-of-line 1)
      (goto-char position))))

(define-key yas-keymap (kbd "C-e") 'yas/goto-end-of-active-field)
(define-key yas-keymap (kbd "C-a") 'yas/goto-start-of-active-field)

;; No dropdowns please, yas
(setq yas-prompt-functions '(yas-ido-prompt yas-completing-prompt))

;; No need to be so verbose
(setq yas-verbosity 1)

;; Wrap around region
(setq yas-wrap-around-region t)

(provide 'setup-yasnippet)
;;; setup-yasnippet.el ends here