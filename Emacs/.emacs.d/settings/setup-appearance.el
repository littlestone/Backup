;;; setup-appearance.el --- tweak Emacs UI settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Don't defer screen updates when performing operations
(setq redisplay-dont-pause t
      linum-delay t
      visible-bell t
      color-theme-is-global t
      auto-image-file-mode t
      font-lock-maximum-decoration t
      truncate-partial-width-windows nil
      scroll-step 1
      scroll-margin 1
      auto-window-vscroll nil
      scroll-conservatively 10000
      scroll-preserve-screen-position 1
      mouse-wheel-scroll-amount '(1 ((shift) . 1)))

;; Smooth scrolling
(setq-default scroll-up-aggressively 0.01
              scroll-down-aggressively 0.01)

;; Window-system tweaks
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1))

;; Highlight current line & keep syntax highlighting
(global-hl-line-mode 1)
(set-face-foreground 'highlight nil)

;; Set custom theme path
(setq custom-theme-directory (concat user-emacs-directory "themes"))
(when (not (file-exists-p custom-theme-directory))
  (make-directory custom-theme-directory))
(dolist
    (path (directory-files custom-theme-directory t "\\w+"))
  (when (file-directory-p path)
    (add-to-list 'custom-theme-load-path path)))

;; Advise load-theme, so that it first disables all custom themes
;; before loading (enabling) another one.
(defadvice load-theme (before theme-dont-propagate activate)
  (mapc #'disable-theme custom-enabled-themes))

;; Load default theme
(load-theme 'monokai t)

(provide 'setup-appearance)
;;; setup-appearance.el ends here
