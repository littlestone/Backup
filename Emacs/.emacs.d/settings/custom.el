;;; custom.el --- tweak Emacs customization settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(cua-mode t nil (cua-base))
 '(display-time-mode t)
 '(global-hl-line-mode t)
 '(package-selected-packages
   (quote
    (impatient-mode realgud pyimport pygen py-yapf pytest pylint py-autopep8 ob-ipython ob-http live-py-mode ein anaconda-mode elpy highlight-indent-guides persistent-scratch buffer-move neotree nyan-prompt nyan-mode info+ rainbow-mode golden-ratio zzz-to-char linum-relative projectile suggest monokai-theme vimish-fold tide queue heap planet-theme darkokai-theme charmap disaster aggressive-indent 2048-game ace-mc multifiles fold-this powerline paren-face solarized-theme solarized-themes web-mode zoom-frm yasnippet yaml-mode wttrin whitespace-cleanup-mode which-key wgrep visual-regexp use-package undo-tree switch-window swiper smex smart-compile slime skewer-mode restart-emacs paredit multiple-cursors minimap markdown-mode magit macrostep litable key-chord json-mode js2-mode imenu-anywhere iedit ido-vertical-mode ido-ubiquitous ido-hacks ido-at-point highlight-escape-sequences google-translate google-this git-timemachine git-gutter-fringe frame-cmds focus flycheck flx-ido find-file-in-project fill-column-indicator expand-region elmacro elisp-lint elisp-format dired-single dired-details csharp-mode company browse-kill-ring ascii ace-jump-mode)))
 '(safe-local-variable-values (quote ((auto-save-interval . 1000))))
 '(send-mail-function (quote smtpmail-send-it))
 '(show-paren-mode t)
 '(smtpmail-smtp-server "mail11.corp.local")
 '(smtpmail-smtp-service 25)
 '(tool-bar-mode nil)
 '(unibasic-case-indent -3)
 '(unibasic-default-indent 3)
 '(unibasic-initial-indent 3))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Source Code Pro" :foundry "outline" :slant normal :weight normal :height 102 :width normal))))
 '(company-scrollbar-bg ((t (:background "#184678"))))
 '(company-scrollbar-fg ((t (:background "#143a63"))))
 '(company-tooltip ((t (:inherit default :background "#113256"))))
 '(company-tooltip-common ((t (:inherit font-lock-constant-face))))
 '(company-tooltip-selection ((t (:inherit font-lock-function-name-face)))))

(provide 'custom)
;;; custom.el ends here
