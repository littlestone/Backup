;;; setup-company.el --- Modular in-buffer completion framework for Emacs -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'company)

;; Use company-mode in all buffers
(add-hook 'after-init-hook 'global-company-mode)

;; To use company-mode in all buffers
(with-eval-after-load 'company
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (define-key company-active-map (kbd "TAB") #'company-indent-or-complete-common)
  (setq company-tooltip-align-annotations t))

;; Change company-mode nasty default color & behaviors
(require 'color)
(let ((bg (face-attribute 'default :background)))
  (custom-set-faces
   `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
   `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
   `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
   `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
   `(company-tooltip-common ((t (:inherit font-lock-constant-face))))))

(provide 'setup-company)
;;; setup-company.el ends here
