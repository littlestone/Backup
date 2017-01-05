;;; setup-sane-defaults.el --- Emacs sane default settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Run at full power please
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; Better defaults
(setq select-enable-primary nil
      visible-bell t
      apropos-do-all t
      load-prefer-newer t
      electric-pair-mode t
      mouse-yank-at-point t
      require-final-newline t
      save-interprogram-paste-before-kill t)

;; Default directory to ~/.emacs.d
(setq default-directory user-emacs-directory)

;; Allow pasting selection outside of Emacs
(setq select-enable-clipboard t)

;; Auto refresh buffers
(global-auto-revert-mode 1)

;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; Show keystrokes in progress
(setq echo-keystrokes 0.1)

;; Move files to trash when deleting
(setq delete-by-moving-to-trash t)

;; Real emacs knights don't use shift to mark things
(setq shift-select-mode nil)

;; Transparently open compressed files
(auto-compression-mode t)

;; Enable syntax highlighting for older Emacsen that have it off
(global-font-lock-mode t)

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; UTF-8 please
(setq locale-coding-system 'utf-8-unix) ; pretty
(set-terminal-coding-system 'utf-8-unix) ; pretty
(set-keyboard-coding-system 'utf-8-unix) ; pretty
(setq default-buffer-file-coding-system 'utf-8-unix) ; please
(prefer-coding-system 'utf-8-unix) ; with sugar on top

;; Enable prettify symbols mode
(global-prettify-symbols-mode)
(setq prettify-symbols-unprettify-at-point 'right-edge)

;; Show active region
(transient-mark-mode 1)
(make-variable-buffer-local 'transient-mark-mode)
(put 'transient-mark-mode 'permanent-local t)
(setq-default transient-mark-mode t)

;; Turn on abbrev mode globally
(setq-default abbrev-mode t)
(setq save-abbrevs 'silently)

;; Remove text in active region if inserting text
(delete-selection-mode 1)

;; Turn on highlight matching brackets when cursor is on one
(show-paren-mode 1)

;; Don't highlight matches with jump-char - it's distracting
(setq jump-char-lazy-highlight-face nil)

;; Always display line and column numbers
(setq line-number-mode t)
(setq column-number-mode t)

;; Lines should be 80 characters wide, not 72
(setq fill-column 80)

;; Save a list of recent files visited. (open recent file with C-x f)
(recentf-mode 1)
(setq recentf-max-saved-items 100) ;; just 20 is too recent

;; Save minibuffer history
(savehist-mode 1)
(setq history-length 1000)

;; Remember cursor position, for emacs 25.1 or later
(save-place-mode 1)

;; Undo/redo window configuration with C-c <left>/<right>
(winner-mode 1)

;; Never insert tabs
(set-default 'indent-tabs-mode nil)

;; Try indent first, otherwise try to complete the thing at point
(setq tab-always-indent 'complete)

;; Show me empty lines after buffer end
(set-default 'indicate-empty-lines t)

;; Easily navigate sillycased words
(global-subword-mode 1)

;; Don't break lines for me, please
(setq-default truncate-lines t)

;; Allow recursive minibuffers
(setq enable-recursive-minibuffers t)

;; Don't be so stingy on the memory, we have lots now. It's the distant future.
(setq gc-cons-threshold 20000000)

;; Sentences do not need double spaces to end. Period.
(set-default 'sentence-end-double-space nil)

;; 80 chars is a good width.
(set-default 'fill-column 80)

;; Rectangles and cua
(setq cua-enable-cua-keys nil) ;; only for rectangles
(cua-mode t)

;; Add parts of each file's directory to the buffer name if not unique
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; A saner compile
(setq compilation-ask-about-save nil)         ; I'm not scared of saving everyting
(setq compilation-scroll-output 'next-error)  ; stop on the first error
(setq compilation-skip-threshold 2)           ; don't stop on info or warnings

;; A saner ediffx
(setq ediff-diff-options "-w")
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; Easily search for non-ASCII characters 
(setq search-default-mode #'char-fold-to-regexp)
(setq replace-char-fold t)

;; No electric indent
(setq electric-indent-mode nil)

;; Electric pair: automatically close parenthesis, curly brace etc.
(add-hook 'prog-mode-hook 'electric-pair-mode)

;; Nic says eval-expression-print-level needs to be set to nil (turned off) so
;; that you can always see what's happening.
(setq eval-expression-print-level nil)

;; Make eww the default broswer in Emacs
(setq browse-url-browser-function 'eww-browse-url)
(setq shr-color-visible-luminance-min 90)

;; Offer to create parent directories if they do not exist
;; http://iqbalansari.github.io/blog/2014/12/07/automatically-create-parent-directories-on-visiting-a-new-file-in-emacs/
(defun my-create-non-existent-directory ()
  (let ((parent-directory (file-name-directory buffer-file-name)))
    (when (and (not (file-exists-p parent-directory))
               (y-or-n-p (format "Directory `%s' does not exist! Create it? " parent-directory)))
      (make-directory parent-directory t))))
(add-to-list 'find-file-not-found-functions 'my-create-non-existent-directory)

;; When popping the mark, continue popping until the cursor actually moves
;; Also, if the last command was a copy - skip past all the expand-region cruft.
(defadvice pop-to-mark-command (around ensure-new-position activate)
  (let ((p (point)))
    (when (eq last-command 'save-region-or-current-line)
      ad-do-it
      ad-do-it
      ad-do-it)
    (dotimes (i 10)
      (when (= p (point)) ad-do-it))))
(setq set-mark-command-repeat-pop t)

;; Don't open files from the workspace in a new frame
(setq ns-pop-up-frames nil)

;; Support for ANSI colors in shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Auto-indentation by Default
(add-hook 'prog-mode-hook (lambda () (electric-indent-local-mode +1)))

(provide 'setup-sane-defaults)
;;; setup-sane-defaults.el ends here
