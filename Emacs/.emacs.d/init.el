;;; init.el --- Live in Emacs! -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Reduce GC frenqency to speed up Emacs

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq gc-cons-threshold (* 100 1024 1024))

;; Turn off mouse interface early in startup to avoid momentary display
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; No splash screen please ... jeez
(setq inhibit-startup-message t)

;; Suppressing ad-handle-definition Warnings when functions are redefined with defadvice
(setq ad-redefinition-action 'accept)

;; Set path to dependencies
(defvar --settings-dir (expand-file-name "settings" user-emacs-directory))
(when (not (file-exists-p --settings-dir))
  (make-directory --settings-dir))
(add-to-list 'load-path --settings-dir)

(defvar --site-lisp-dir (expand-file-name "site-lisp" user-emacs-directory))
(when (not (file-exists-p --site-lisp-dir))
  (make-directory --site-lisp-dir))
(add-to-list 'load-path --site-lisp-dir)

(defvar --defuns-dir (expand-file-name "defuns" user-emacs-directory))
(when (not (file-exists-p --defuns-dir))
  (make-directory --defuns-dir))
(add-to-list 'load-path --defuns-dir)

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" --settings-dir))
(load custom-file)

;; Set up appearance early
(require 'setup-appearance)

;; Common lisp library
(eval-when-compile (require 'cl))

;; Settings for currently logged in user
(defvar --user-settings-dir (expand-file-name "users" user-emacs-directory))
(when (not (file-exists-p --user-settings-dir))
  (make-directory --user-settings-dir))
(setq --user-settings-dir (concat --user-settings-dir "/" user-login-name))
(when (not (file-exists-p --user-settings-dir))
  (make-directory --user-settings-dir))
(add-to-list 'load-path --user-settings-dir)

;; Add external projects to load path
(dolist (project (directory-files --site-lisp-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

;; Install packages
(require 'setup-package)

;; Load all 3rd extensions
(dolist (file (directory-files --site-lisp-dir t "\\w+"))
  (when (file-regular-p file)
    (load file)))

;; Load all user defined elisp functions
(dolist (file (directory-files --defuns-dir t "\\w+"))
  (when (file-regular-p file)
    (load file)))

;; Load all user specific settings
(dolist (file (directory-files --user-settings-dir t "\\w+"))
  (when (file-regular-p file)
    (load file)))

;; Setup extensions
(require 'setup-ffip)
(require 'setup-misc)
(require 'setup-magit)
(require 'setup-rgrep)
(require 'setup-hippie)
(require 'setup-python)
(require 'setup-company)
(require 'setup-paredit)
(require 'setup-diminish)
(require 'setup-flycheck)
(require 'setup-register)
(require 'setup-yasnippet)
(require 'setup-mode-mappings)

;; Language specific setup files
(eval-after-load 'cc-mode '(require 'setup-clang))
(eval-after-load 'typescript-mode '(require 'setup-typescript))

;; Load stuff on demand
(autoload 'slime "setup-slime" nil t)
(autoload 'skewer-start "setup-skewer" nil t)
(autoload 'skewer-demo "setup-skewer" nil t)
(eval-after-load 'ido '(require 'setup-ido))
(eval-after-load 'org '(require 'setup-org))
(eval-after-load 'dired '(require 'setup-dired))
(eval-after-load 'shell '(require 'setup-shell))

;; OS specific settings
(setq is-windows (equal system-type 'windows-nt))
(setq is-linux (equal system-type 'gnu/linux))
(when is-linux (require 'setup-linux))
(when is-windows (require 'setup-windows))

;; Let's start with a smattering of sanity
(require 'setup-sane-defaults)

;; Setup key bindings
(require 'setup-key-chord)
(require 'setup-key-bindings)

;;; init.el ends here
