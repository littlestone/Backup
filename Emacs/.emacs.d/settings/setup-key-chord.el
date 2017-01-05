;;; setup-key-chord.el --- Map pairs of simultaneously pressed keys to commands -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'key-chord)
(key-chord-mode 1)

(setq key-chord-one-key-delay 0.16)
(key-chord-define-global ",," 'ibuffer)
(key-chord-define-global ",a" 'ace-jump-char-mode)
(key-chord-define-global ",b" 'goto-scratch)
(key-chord-define-global ",c" 'cleanup-buffer)
(key-chord-define-global ",d" 'kill-this-buffer-unless-scratch)
(key-chord-define-global ",e" 'eval-buffer)
(key-chord-define-global ",f" 'recentf-ido-find-file)
(key-chord-define-global ",g" 'google-translate-at-point)
(key-chord-define-global ",l" 'list-packages)
(key-chord-define-global ",q" 'read-only-mode)
(key-chord-define-global ",r" 'rgrep-fullscreen)
(key-chord-define-global ",s" 'swiper)
(key-chord-define-global ",t" 'neotree-toggle)
(key-chord-define-global ",w" 'whitespace-mode)
(key-chord-define-global ",z" 'eshell)
(key-chord-define-global "JJ" 'quick-switch-buffer)

(provide 'setup-key-chord)
;;; setup-key-chord.el ends here
