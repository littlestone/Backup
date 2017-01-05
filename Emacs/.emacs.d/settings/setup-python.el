;;; setup-python.el --- Emacs Python Language Settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Emacs Python Development Environment
(require 'elpy)
(add-hook 'python-mode-hook 'elpy-enable)

;; Code navigation, documentation lookup and completion for Python
(require 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-eldoc-mode)

;; Provides commands, which use the external autopep8 tool to tidy up the current buffer according to Python’s PEP8
(require 'py-autopep8)
(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)

;; python-mode keybindings
(define-key python-mode-map (kbd "C-c C-<return>") 'elpy-shell-send-current-statement)
(define-key python-mode-map (kbd "C-c C-d") 'elpy-doc)

(provide 'setup-python)
;;; setup-python.el ends here
