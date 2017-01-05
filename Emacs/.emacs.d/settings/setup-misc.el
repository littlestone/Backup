;;; setup-misc.el --- Emacs miscellaneous settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Some nonstandard editing and utility commands for Emacs
(require 'misc)

;; Seed the random-number generator
(random t)

;; Keep region when undoing in region
(defadvice undo-tree-undo (around keep-region activate)
  (if (use-region-p)
      (let ((m (set-marker (make-marker) (mark)))
            (p (set-marker (make-marker) (point))))
        ad-do-it
        (goto-char p)
        (set-mark m)
        (set-marker p nil)
        (set-marker m nil))
    ad-do-it))

;; Switch from escaped octal character code to escaped HEX
(setq standard-display-table (make-display-table))
(let ((i ?\x80) hex hi low)
  (while (<= i ?\xff)
    (setq hex (format "%x" i))
    (setq hi (elt hex 0))
    (setq low (elt hex 1))
    (aset standard-display-table (unibyte-char-to-multibyte i)
          (vector (make-glyph-code ?\\ 'escape-glyph)
                  (make-glyph-code ?x 'escape-glyph)
                  (make-glyph-code hi 'escape-glyph)
                  (make-glyph-code low 'escape-glyph)))
    (setq i (+ i 1))))

;; Window-system tweaks
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (blink-cursor-mode -1))

;; Whitespace-style
(setq whitespace-style (quote (spaces tabs newline space-mark tab-mark newline-mark)))
(setq whitespace-display-mappings
      ;; all numbers are Unicode codepoint in decimal. try (insert-char 182 ) to see it
      '((space-mark 32 [183] [46]) ; 32 SPACE, 183 MIDDLE DOT 「·」, 46 FULL STOP 「.」
        (newline-mark 10 [182 10]) ; 10 LINE FEED
        (tab-mark 9 [9655 9] [92 9]) ; 9 TAB, 9655 WHITE RIGHT-POINTING TRIANGLE 「▷」
        ))

;; Highlight current line & keep syntax highlighting
(global-hl-line-mode 1)
(set-face-foreground 'highlight nil)

;; 中文使用微软雅黑字体
(set-fontset-font "fontset-default" 'gb18030 '("Microsoft YaHei" . "unicode-bmp"))

;; Use normal tabs in makefiles
(add-hook 'makefile-mode-hook 'indent-tabs-mode)

;; A bit of misc cargo culting in misc.el
(setq xterm-mouse-mode t)

;; Don't use expand-region fast keys
(setq expand-region-fast-keys-enabled nil)

;; Show expand-region command used
(setq er--show-expansion-message t)

;; Represent undo-history as an actual tree (visualize with C-x u)
(setq undo-tree-mode-lighter "")
(global-undo-tree-mode)

;; Browse kill ring
(setq browse-kill-ring-quit-action 'save-and-restore)

;; Emacs powerline
(powerline-default-theme)

;; Dimming parentheses
(global-paren-face-mode)

;; Highlight escape sequences
(hes-mode)
(put 'font-lock-regexp-grouping-backslash 'face-alias 'font-lock-builtin-face)

;; Sidebar showing a "mini-map" of a buffer
(setq minimap-minimum-width 15)
(setq minimap-window-location 'right)

;; Persistent scratch
(persistent-scratch-setup-default)

;; Displays available keybindings in popup
(which-key-mode)

;; Intelligently call whitespace-cleanup on save
(global-whitespace-cleanup-mode 1)

;; Launching google searches from within Emacs
(google-this-mode 1)

;; Vim-like text folding for Emacs
(vimish-fold-global-mode 1)

;; Nyan Cat shows position in current buffer in mode-line
(nyan-mode 1)

;; Nyan cat on the eshell prompt
(add-hook 'eshell-load-hook 'nyan-prompt-enable)

;; Edit multiple regions in the same way simultaneously
(require 'iedit)

;; Highlight indent guides
(require 'highlight-indent-guides)
(setq highlight-indent-guides-method 'character)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(set-face-foreground 'highlight-indent-guides-character-face "dimgray")

;; Graphically indicate the location of the fill column
(when window-system
  (require 'fill-column-indicator)
  (setq fci-rule-column 78)
  (define-globalized-minor-mode global-fci-mode fci-mode
    (lambda ()
      (if buffer-file-name
          (fci-mode 1))))
  (global-fci-mode 1)
  (unless window-system
    (error "Fill-column-indicator only works on window systems")))

;; Google translate
(require 'google-translate)
(setq google-translate-show-phonetic t)
(setq google-translate-pop-up-buffer-set-focus t)
(setq google-translate-default-source-language "en")
(setq google-translate-default-target-language "zh-CN")
(setq google-translate-translation-directions-alist
      '(("en" . "zh-CN")
        ("zh-CN" . "en")
        ("fr" . "zh-CN")
        ("zh-CN" . "fr")
        ("en" . "fr")
        ("fr" . "en")))

;; Add to webjump hotlist (C-x w)
(eval-after-load "webjump"
  '(setq webjump-sites
         (append '(("stackoverflow" .
                    [simple-query
                     "http://stackoverflow.com/"
                     "http://stackoverflow.com/search?q="
                     ""])
                   ("(emacs)" .
                    [simple-query
                     "emacs.stackexchange.com"
                     "http://emacs.stackexchange.com/search?q="
                     ""])
                   ("百度" .
                    [simple-query
                     "www.baidu.com"
                     "http://www.baidu.com/s?wd="
                     ""])
                   ("海词" .
                    [simple-query
                     "dict.cn"
                     "http://dict.cn/"
                     ""])
                   ("汉典" .
                    [simple-query
                     "www.zdic.net"
                     "http://www.zdic.net/sousuo/?q="
                     ""])
                   ("法语助手" .
                    [simple-query
                     "www.frdic.com"
                     "http://www.frdic.com/dicts/fr/"
                     ""])
                   ("Urban Dictionary" .
                    [simple-query
                     "www.urbandictionary.com"
                     "http://www.urbandictionary.com/define.php?term="
                     ""]))
                 webjump-sample-sites)))

;; Weather in Emacs
(require 'wttrin)
(setq wttrin-default-cities '("Langley" "Surrey" "Vancouver" "Montreal" "Dalian" "Beijing"))

;; Write backup files to own directory
(defvar --backups-dir (concat user-emacs-directory "backups/"))
(setq backup-directory-alist
      `(("." . ,--backups-dir)
        (,tramp-file-name-regexp nil))
      auto-save-interval 20   ; save every 20 characters typed (this is the minimum)
      backup-by-copying t     ; don't clobber symlinks
      kept-new-versions 10    ; keep 10 latest versions
      kept-old-versions 0     ; don't bother with old versions
      delete-old-versions t   ; don't ask about deleting old versions
      version-control t       ; number backups
      vc-make-backup-files t  ; backup version controlled file
      )

;; Store all backup and autosave files in the temp dir
(defvar --temp-dir (concat user-emacs-directory "temp/"))
(setq savehist-file (expand-file-name "history" --temp-dir)
      save-place-file (expand-file-name "places" --temp-dir)
      recentf-save-file (expand-file-name "recentf" --temp-dir)
      abbrev-file-name (expand-file-name "abbrev_defs" --temp-dir)
      tramp-persistency-file-name (expand-file-name "tramp" --temp-dir)
      url-configuration-directory (expand-file-name "url" --temp-dir)
      url-cookie-file (expand-file-name "cookies" url-configuration-directory)
      eww-bookmarks-directory url-configuration-directory
      vimish-fold-dir (expand-file-name "vimish-fold" --temp-dir)
      mc/list-file (expand-file-name ".mc-lists.el" --temp-dir)
      smex-save-file (expand-file-name "smex-items" --temp-dir)
      litable-list-file (expand-file-name ".litable-lists.el" --temp-dir)
      ido-save-directory-list-file (expand-file-name "ido.last" --temp-dir)
      auto-save-file-name-transforms `((".*" ,--temp-dir t))
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.auto-saves-" --temp-dir))

;; Colorize color names in buffers
(add-hook 'html-mode-hook 'rainbow-mode)
(add-hook 'css-mode-hook 'rainbow-mode)

;; Emacs server
(require 'server)
(unless (server-running-p)
  (server-start))

(provide 'setup-misc)
;;; setup-misc.el ends here
