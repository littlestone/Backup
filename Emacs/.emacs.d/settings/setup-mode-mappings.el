;;; setup-mode-mappings.el --- Emacs mode mappings settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; YAML
(autoload 'yaml-mode "yaml-mode")
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))

;; Emacs lisp
(add-to-list 'auto-mode-alist '("Carton$" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("Cask$" . emacs-lisp-mode))

;; CSS
(add-to-list 'auto-mode-alist '("\\.scss$" . css-mode))

;; Restclient
(add-to-list 'auto-mode-alist '("\\.restclient$" . restclient-mode))

;; HTML
(add-to-list 'auto-mode-alist '("\\.html\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.tag$" . html-mode))
(add-to-list 'auto-mode-alist '("\\.vm$" . html-mode))
(add-to-list 'auto-mode-alist '("\\.ejs$" . html-mode))

;; SVG
(add-to-list 'auto-mode-alist '("\\.svg$" . image-mode))

;; JavaScript
(autoload 'js2-mode "js2-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.json$" . json-mode))
(add-to-list 'auto-mode-alist '("\\.jshintrc$" . javascript-mode))

;; Snippets
(add-to-list 'auto-mode-alist '("yasnippet/snippets" . snippet-mode))
(add-to-list 'auto-mode-alist '("\\.yasnippet$" . snippet-mode))

;; Markdown
(autoload 'markdown-mode "markdown-mode")
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))

;; org-mode
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(provide 'setup-mode-mappings)
;;; setup-mode-mappings.el ends here
