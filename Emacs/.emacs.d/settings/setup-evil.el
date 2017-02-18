;;; setup-evil.el --- tweak evil settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;;; Evil is an extensible vi layer for Emacs
(require 'evil)
(evil-mode 1)

;; Vimish Fold
(require 'evil-vimish-fold)
(evil-vimish-fold-mode 1)

;; Increment / Decrement binary, octal, decimal and hex literals
(require 'evil-numbers)
(define-key evil-normal-state-map (kbd "C-c +") 'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "C-c -") 'evil-numbers/dec-at-pt)
(define-key evil-normal-state-map (kbd "<kp-add>") 'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "<kp-subtract>") 'evil-numbers/dec-at-pt)

;; I want the Emacs keybinding to work in Evil
(define-key evil-normal-state-map (kbd "C-y") 'yank)
(define-key evil-insert-state-map (kbd "C-y") 'yank)
(define-key evil-visual-state-map (kbd "C-y") 'yank)
(define-key evil-normal-state-map (kbd "C-r") 'isearch-backward-regexp)
(define-key evil-insert-state-map (kbd "C-e") 'end-of-line)
(define-key evil-motion-state-map (kbd "C-e") 'evil-end-of-line)
(define-key evil-insert-state-map (kbd "C-w") 'evil-delete)
(define-key evil-visual-state-map (kbd "C-w") 'evil-delete)
(define-key evil-insert-state-map (kbd "C-t") nil) ; my key-bindings for multiple-cursors
(define-key evil-normal-state-map (kbd "M-.") nil) ; default key-bindings for `elisp-slime-nav'
(key-chord-define evil-insert-state-map  "jk" 'evil-normal-state)

;; Don't wait for any other keys after escape is pressed.
(setq evil-esc-delay 0)

;; Set evil-shift-width to 2 space
(setq evil-shift-width 2)

;; Use Vim visual selection style, i.e. treatment of character under point
(setq evil-want-visual-char-semi-exclusive t)

;; Get new undo units when moving the cursor in insert mode,
;; but replace operations are undone in one step.
(setq evil-want-fine-undo 'fine)

;; Change cursor in different modes.
(setq evil-default-cursor 'box)
(setq evil-normal-state-cursor 'box)
(setq evil-visual-state-cursor 'hollow)
(setq evil-replace-state-cursor 'hbar)

;; Make sure ESC gets back to normal state and quits things.
(define-key evil-insert-state-map [escape] 'evil-normal-state)
(define-key evil-visual-state-map [escape] 'evil-normal-state)
(define-key evil-emacs-state-map [escape] 'evil-normal-state)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-map [escape] 'abort-recursive-edit)
(define-key minibuffer-local-ns-map [escape] 'abort-recursive-edit)
(define-key minibuffer-local-completion-map [escape] 'abort-recursive-edit)
(define-key minibuffer-local-must-match-map [escape] 'abort-recursive-edit)
(define-key minibuffer-local-isearch-map [escape] 'abort-recursive-edit)

;; Enter insert mode to edit a commit message
(add-hook 'git-commit-mode-hook 'evil-insert-state)

(provide 'setup-evil)
;;; setup-evil.el ends here
