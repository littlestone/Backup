;;; setup-ido.el --- Interactively Do Things -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; IDO basic settings
(require 'ido)
(setq ido-enable-flex-matching t ; flexibly match names via fuzzy matching
      ido-everywhere t           ; use ido-mode everywhere, in buffers and for finding files
      ido-use-virtual-buffers t  ; effectively adds recentf entries to the buffer list
      ido-enable-prefix nil
      ido-case-fold nil
      ido-auto-merge-work-directories-length -1
      ido-create-new-buffer 'always
      ido-use-filename-at-point nil
      ido-max-prospects 10)
(ido-mode 1)

;; Put more IDO in your IDO
(require 'ido-hacks)

;; Try out flx-ido for better flex matching between words
(require 'flx-ido)
(flx-ido-mode 1)

;; disable ido faces to see flx highlights.
(setq ido-use-faces nil)

;; flx-ido looks better with ido-vertical-mode
(require 'ido-vertical-mode)
(ido-vertical-mode)

;; C-n/p is more intuitive in vertical layout
(setq ido-vertical-define-keys 'C-n-C-p-up-down-left-right)

;; Smart M-x is smart
(require 'smex)
(smex-initialize)

;; Always rescan buffer for imenu
(set-default 'imenu-auto-rescan t)

;; Ido at point (C-,)
(require 'ido-at-point)
(ido-at-point-mode)

;; Patch to avoid ido-ubiquitous bytecomp warning message on startup
(defvar ido-cur-list nil)
(defvar ido-require-match nil)
(defvar ido-cr+-debug-mode nil)

;; Use ido everywhere
(require 'ido-ubiquitous)
(ido-ubiquitous-mode 1)

;; Fix ido-ubiquitous for newer packages
(defmacro ido-ubiquitous-use-new-completing-read (cmd package)
  `(eval-after-load ,package
     '(defadvice ,cmd (around ido-ubiquitous-new activate)
        (let ((ido-ubiquitous-enable-compatibility nil))
          ad-do-it))))

(ido-ubiquitous-use-new-completing-read webjump 'webjump)
(ido-ubiquitous-use-new-completing-read yas-expand 'yasnippet)
(ido-ubiquitous-use-new-completing-read yas-visit-snippet-file 'yasnippet)

(provide 'setup-ido)
;;; setup-ido.el ends here
