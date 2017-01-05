;;; setup-diminish.el --- Diminished modes are minor modes with no modeline display -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Unclutter the modeline
(require 'diminish)

(eval-after-load "eldoc" '(diminish 'eldoc-mode))
(eval-after-load "abbrev" '(diminish 'abbrev-mode))
(eval-after-load "company" '(diminish 'company-mode))
(eval-after-load "paredit" '(diminish 'paredit-mode))
(eval-after-load "subword" '(diminish 'subword-mode))
(eval-after-load "tagedit" '(diminish 'tagedit-mode))
(eval-after-load "flycheck" '(diminish 'flycheck-mode))
(eval-after-load "which-key" '(diminish 'which-key-mode))
(eval-after-load "yasnippet" '(diminish 'yas-minor-mode))
(eval-after-load "google-this" '(diminish 'google-this-mode))
(eval-after-load "golden-ratio" '(diminish 'golden-ratio-mode))
(eval-after-load "whitespace-cleanup-mode" '(diminish 'whitespace-cleanup-mode))

(defmacro rename-modeline (package-name mode new-name)
  `(eval-after-load ,package-name
     '(defadvice ,mode (after rename-modeline activate)
        (setq mode-name ,new-name))))

(rename-modeline "js2-mode" js2-mode "JS2")

(provide 'setup-diminish)
;;; setup-diminish.el ends here
