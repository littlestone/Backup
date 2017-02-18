;;; setup-key-bindings.el --- Emacs key-bindings settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Make PC keyboard's Win key or other to type Super or Hyper, for emacs running on Windows.
(setq w32-pass-lwindow-to-system nil)
(setq w32-lwindow-modifier 'super) ; Left Windows key
(setq w32-pass-rwindow-to-system nil)
(setq w32-rwindow-modifier 'super) ; Right Windows key
(setq w32-pass-apps-to-system nil)
(setq w32-apps-modifier 'hyper) ; Menu/App key

;; I don't need to kill emacs that easily
;; the mnemonic is C-x REALLY QUIT
(global-set-key (kbd "C-x r q") 'save-buffers-kill-terminal)
(global-set-key (kbd "C-x C-n") 'make-frame-command)
(global-set-key (kbd "C-x C-c") 'delete-frame)

;; Completion that uses many different methods to find options.
(global-set-key (kbd "C-,") 'completion-at-point)
(global-set-key (kbd "C-.") 'hippie-expand-no-case-fold)
(global-set-key (kbd "C-:") 'hippie-expand-lines)

;; Copy line above (require 'misc)
(require 'misc)
(global-set-key (kbd "s-.") 'copy-from-above-command)

;; Smart M-x
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-c M-x") 'execute-extended-command)

;; Expand region (increases selected region by semantic units)
(global-set-key (kbd "C-=") 'er/expand-region)
(global-set-key (kbd "C--") 'er/contract-region)

;; Multiple curosrs
(global-set-key (kbd "C-c C-a") 'mc/edit-lines)
(global-set-key (kbd "C-c C-e") 'mc/edit-ends-of-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C->") 'mc/mark-all-dwim)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-S-<mouse-1>") 'mc/add-cursor-on-click)

;; Extra multiple cursors stuff
(global-set-key (kbd "C-~") 'mc/reverse-regions)
(global-set-key (kbd "M-~") 'mc/sort-regions)
(global-set-key (kbd "H-~") 'mc/insert-numbers)

;; Add Multiple Cursors with Ace Jump
(global-set-key (kbd "C-M-(") 'ace-mc-add-multiple-cursors)
(global-set-key (kbd "C-M-)") 'ace-mc-add-single-cursor)

;; Set anchor to start rectangular-region-mode
(global-set-key (kbd "H-SPC") 'set-rectangular-region-anchor)

;; Enable Emacs column selection using mouse
(global-set-key (kbd "M-<down-mouse-1>") 'ignore)
(global-set-key (kbd "M-<down-mouse-1>") #'mouse-start-rectangle)

;; Transpose stuff with M-t
(global-unset-key (kbd "M-t")) ;; which used to be transpose-words
(global-set-key (kbd "M-t c") 'transpose-chars)
(global-set-key (kbd "M-t l") 'transpose-lines)
(global-set-key (kbd "M-t w") 'transpose-words)
(global-set-key (kbd "M-t s") 'transpose-sexps)
(global-set-key (kbd "M-t p") 'transpose-params)

;; Kill entire line with prefix argument
(global-set-key [remap paredit-kill] (bol-with-prefix paredit-kill))
(global-set-key [remap org-kill-line] (bol-with-prefix org-kill-line))
(global-set-key [remap kill-line] (bol-with-prefix kill-line))

;; Killing text
(global-set-key (kbd "C-S-k") 'kill-and-retry-line)
(global-set-key (kbd "C-M-w") 'kill-to-beginning-of-line)
(global-set-key (kbd "M-h") 'kill-region-or-backward-word)

;; Use M-w for copy-line if no active region
(global-set-key (kbd "M-w") 'save-region-or-current-line)
(global-set-key (kbd "M-W") 'copy-whole-lines)

;; Zap to char
(global-set-key (kbd "M-z") 'zap-up-to-char)
(global-set-key (kbd "M-Z") (lambda (char) (interactive "cZap to char: ") (zap-to-char 1 char)))
(global-set-key (kbd "s-z") (lambda (char) (interactive "cZap up to char backwards: ") (zap-up-to-char -1 char)))
(global-set-key (kbd "s-Z") (lambda (char) (interactive "cZap to char backwards: ") (zap-to-char -1 char)))
(global-set-key (kbd "C-c M-z") 'zzz-up-to-char)
(global-set-key (kbd "C-c M-Z") 'zzz-to-char)

;; Jump to a definition in the current file. (This is awesome)
(global-set-key (kbd "C-x C-i") 'imenu-anywhere)

;; File finding
(global-set-key (kbd "C-x f") 'ffap)
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Toggle two most recent buffers
(fset 'quick-switch-buffer [?\C-x ?b return])
(global-set-key (kbd "C-c C-b") 'quick-switch-buffer)

;; Bury current buffer
(global-set-key (kbd "C-c y") 'bury-buffer)

;; Kill current buffer
(global-set-key (kbd "C-x k") 'kill-this-buffer-unless-scratch)

;; Revert current buffer without any fuss
(global-set-key (kbd "s-<escape>") (λ (revert-buffer t t)))

;; Revert current buffer with coding system
(global-set-key (kbd "C-x M-r") 'revert-buffer-with-coding-system)

;; Edit file with sudo
(global-set-key (kbd "M-s e") 'sudo-edit)

;; Copy file path to kill ring
(global-set-key (kbd "C-x M-w") 'copy-current-file-path)

;; Window switching
(windmove-default-keybindings) ;; Shift+direction
(global-set-key (kbd "C-x o") 'switch-window) ;; the visual way
(global-set-key (kbd "C-x -") 'toggle-window-split)
(global-set-key (kbd "C-x C--") 'rotate-windows)
(global-set-key (kbd "C-x 3") 'split-window-right-and-move-there-dammit)

;; Resize window easily
(global-set-key (kbd "C-M-S-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-M-S-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-M-S-<up>") 'shrink-window)
(global-set-key (kbd "C-M-S-<down>") 'enlarge-window)

;; Zoom frame font size
(global-set-key (kbd "C-S-<wheel-up>") 'zoom-frm-in)
(global-set-key (kbd "C-S-<wheel-down>") 'zoom-frm-out)
(global-set-key (kbd "C-S-<mouse-4>") 'zoom-frm-in)
(global-set-key (kbd "C-S-<mouse-5>") 'zoom-frm-out)

;; Swap buffer
(global-set-key (kbd "M-s-<up>") 'buf-move-up)
(global-set-key (kbd "M-s-<down>") 'buf-move-down)
(global-set-key (kbd "M-s-<left>") 'buf-move-left)
(global-set-key (kbd "M-s-<right>") 'buf-move-right)

;; Add region to *multifile*
(global-set-key (kbd "C-!") 'mf/mirror-region-in-multifile)

;; Indentation help
(global-set-key (kbd "M-j") (λ (join-line -1)))

;; Help should search more than just commands
(global-set-key (kbd "<f1> a") 'apropos)

;; Should be able to eval-and-replace anywhere.
(global-set-key (kbd "C-c C-e") 'eval-and-replace)

;; Navigation bindings
(global-set-key [remap goto-line] 'goto-line-with-feedback)
(global-set-key (kbd "C-<next>") 'scroll-up-half)
(global-set-key (kbd "C-<prior>") 'scroll-down-half)
(global-set-key (kbd "C-<home>") 'beginning-of-buffer)
(global-set-key (kbd "C-<end>") 'end-of-buffer)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)

;; Webjump let's you quickly search google, wikipedia, emacs wiki
(global-set-key (kbd "C-x g") 'webjump)
(global-set-key (kbd "C-x M-g") 'browse-url-at-point)

;; Incremental search
(global-set-key (kbd "M-s-.") 'isearch-forward-symbol-at-point)
(global-set-key (kbd "M-s-h .") 'highlight-symbol-at-point)
(global-set-key (kbd "M-s-h l") 'highlight-lines-matching-regexp)
(global-set-key (kbd "M-s-h r") 'highlight-regexp)
(global-set-key (kbd "M-s-h u") 'unhighlight-regexp)

;; Like isearch, but adds region (if any) to history and deactivates mark
(global-set-key (kbd "C-s") 'isearch-forward-use-region)
(global-set-key (kbd "C-r") 'isearch-backward-use-region)

;; Like isearch-*-use-region, but doesn't care with the active region
(global-set-key (kbd "C-S-s") 'isearch-forward)
(global-set-key (kbd "C-S-r") 'isearch-backward)

;; Move more quickly
(global-set-key (kbd "C-S-n") (λ (ignore-errors (next-line 5))))
(global-set-key (kbd "C-S-p") (λ (ignore-errors (previous-line 5))))
(global-set-key (kbd "C-S-f") (λ (ignore-errors (forward-char 5))))
(global-set-key (kbd "C-S-b") (λ (ignore-errors (backward-char 5))))

;; Query replace regex key binding
(global-set-key (kbd "M-&") 'query-replace-regexp)

;; Yank selection in isearch
(define-key isearch-mode-map (kbd "C-o") 'isearch-yank-selection)

;; Create scratch buffer
(global-set-key (kbd "C-c b") 'create-scratch-buffer)

;; Magit
(global-set-key (kbd "C-x m") 'magit-status-fullscreen)
(autoload 'magit-status-fullscreen "magit")

;; Clever newlines
(global-set-key (kbd "C-o") 'open-line-below)
(global-set-key (kbd "C-S-o") 'open-line-above)

;; Duplicate region
(global-set-key (kbd "C-c d") 'duplicate-current-line-or-region)

;; Line movement
(global-set-key (kbd "C-S-<up>") 'move-line-up)
(global-set-key (kbd "C-S-<down>") 'move-line-down)

;; Fold the active region
(global-set-key (kbd "C-c f") 'vimish-fold)
(global-set-key (kbd "C-c C-f") 'vimish-fold-toggle)
(global-set-key (kbd "C-c C-F") 'vimish-fold-toggle-all)
(global-set-key (kbd "C-c M-f") 'vimish-fold-delete)
(global-set-key (kbd "C-c M-F") 'vimish-fold-delete-all)

;; Yank and indent
(global-set-key (kbd "C-S-y") 'yank-unindented)

;; Toggle quotes
(global-set-key (kbd "C-\"") 'toggle-quotes)

;; Sorting
(global-set-key (kbd "M-s l") 'sort-lines)

;; Line number
(global-set-key (kbd "C-c l") 'linum-mode)

;; Shorthand for interactive lambdas
(global-set-key (kbd "C-c M-l") (λ (insert "\u03bb")))

;; Emulation of Vim's visual line selection
(global-set-key (kbd "C-c C-s") 'select-current-line)

;; Emulation of the vi % command
(global-set-key (kbd "%") 'goto-match-paren)

;; Increase number at point (or other change based on prefix arg)
(global-set-key (kbd "<kp-add>") 'change-number-at-point)
(global-set-key (kbd "<kp-subtract>") 'subtract-number-at-point)

;; Browse the kill ring
(global-set-key (kbd "C-x C-y") 'browse-kill-ring)

;; Buffer file functions
(global-set-key (kbd "C-c t") 'touch-buffer-file)
(global-set-key (kbd "C-c C-r") 'rename-current-buffer-file)
(global-set-key (kbd "C-c M-k") 'delete-current-buffer-file)

;; Jump from file to containing directory
(global-set-key (kbd "C-x C-j") 'dired-jump) (autoload 'dired-jump "dired")

;; Visual regexp
(global-set-key (kbd "M-&") 'vr/query-replace)
(global-set-key (kbd "M-/") 'vr/replace)

;; Multi-occur
(global-set-key (kbd "C-c m") 'multi-occur)
(global-set-key (kbd "C-c M-m") 'multi-occur-in-matching-buffers)

;; Display and edit occurances of regexp in buffer
(global-set-key (kbd "C-c o") 'occur)

;; View occurrence in occur-mode
(define-key occur-mode-map (kbd "v") 'occur-mode-display-occurrence)
(define-key occur-mode-map (kbd "n") 'next-line)
(define-key occur-mode-map (kbd "p") 'previous-line)

;; Kill internal process in  process-menu-mode
(define-key process-menu-mode-map (kbd "C-k") 'joaot/delete-process-at-point)

;; Cycle themes
(global-set-key (kbd "C-c C-.") (cycle-themes))

;; Transparent frame
(global-set-key (kbd "C-c .") 'frame-transparency)

;; Find files by name and display results in dired
(global-set-key (kbd "M-s f") 'find-name-dired)

;; Find file in project
(global-set-key (kbd "C-x p") 'find-file-in-project)

;; Find file in project, with specific patterns
(global-unset-key (kbd "C-x C-o")) ;; which used to be delete-blank-lines (also bound to C-c C-<return>)
(global-set-key (kbd "C-x C-o ja") (ffip-create-pattern-file-finder "*.java"))
(global-set-key (kbd "C-x C-o js") (ffip-create-pattern-file-finder "*.js"))
(global-set-key (kbd "C-x C-o jn") (ffip-create-pattern-file-finder "*.json"))
(global-set-key (kbd "C-x C-o ht") (ffip-create-pattern-file-finder "*.html"))
(global-set-key (kbd "C-x C-o jp") (ffip-create-pattern-file-finder "*.jsp"))
(global-set-key (kbd "C-x C-o cs") (ffip-create-pattern-file-finder "*.css"))
(global-set-key (kbd "C-x C-o ft") (ffip-create-pattern-file-finder "*.feature"))
(global-set-key (kbd "C-x C-o cl") (ffip-create-pattern-file-finder "*.clj"))
(global-set-key (kbd "C-x C-o el") (ffip-create-pattern-file-finder "*.el"))
(global-set-key (kbd "C-x C-o ed") (ffip-create-pattern-file-finder "*.edn"))
(global-set-key (kbd "C-x C-o md") (ffip-create-pattern-file-finder "*.md"))
(global-set-key (kbd "C-x C-o rb") (ffip-create-pattern-file-finder "*.rb"))
(global-set-key (kbd "C-x C-o or") (ffip-create-pattern-file-finder "*.org"))
(global-set-key (kbd "C-x C-o ph") (ffip-create-pattern-file-finder "*.php"))
(global-set-key (kbd "C-x C-o tx") (ffip-create-pattern-file-finder "*.txt"))
(global-set-key (kbd "C-x C-o vm") (ffip-create-pattern-file-finder "*.vm"))
(global-set-key (kbd "C-x C-o xm") (ffip-create-pattern-file-finder "*.xml"))
(global-set-key (kbd "C-x C-o in") (ffip-create-pattern-file-finder "*.ini"))
(global-set-key (kbd "C-x C-o pr") (ffip-create-pattern-file-finder "*.properties"))
(global-set-key (kbd "C-x C-o in") (ffip-create-pattern-file-finder "*.ini"))
(global-set-key (kbd "C-x C-o gr") (ffip-create-pattern-file-finder "*.groovy"))
(global-set-key (kbd "C-x C-o ga") (ffip-create-pattern-file-finder "*.gradle"))
(global-set-key (kbd "C-x C-o sc") (ffip-create-pattern-file-finder "*.scala"))
(global-set-key (kbd "C-x C-o ss") (ffip-create-pattern-file-finder "*.scss"))
(global-set-key (kbd "C-x C-o co") (ffip-create-pattern-file-finder "*.conf"))
(global-set-key (kbd "C-x C-o j2") (ffip-create-pattern-file-finder "*.j2"))
(global-set-key (kbd "C-x C-o sh") (ffip-create-pattern-file-finder "*.sh"))
(global-set-key (kbd "C-x C-o ic") (ffip-create-pattern-file-finder "*.ico"))
(global-set-key (kbd "C-x C-o sv") (ffip-create-pattern-file-finder "*.svg"))
(global-set-key (kbd "C-x C-o !") (ffip-create-pattern-file-finder "*"))

;; Save
(global-set-key (kbd "<f2>") 'save-buffer)

;; Save As
(global-set-key (kbd "s-<f2>") 'write-file)

;; Toggle Emacs Lisp debugger
(global-set-key (kbd "<f5>") 'sai/toggle-elisp-debugger)

;; Smart compile
(global-set-key (kbd "<s-f5>") 'smart-compile)

;; Handy hex convert
(global-set-key (kbd "<f6>") '0xc-convert)

;; Hexadecimal editing of data files
(global-set-key (kbd "<s-f6>") 'hexl-mode)

;; Focus
(global-set-key (kbd "<f7>") 'focus-mode)

;; Minimap
(global-set-key (kbd "<s-f7>") 'minimap-mode)

;; Open in desktop
(global-set-key (kbd "<f8>") 'xah-open-in-desktop)

;; Open in external app
(global-set-key (kbd "<s-f8>") 'xah-open-in-external-app)

;; Turn on the menu bar for exploring new modes
(global-set-key (kbd "<f10>") 'menu-bar-mode)

;; Show tool bar
(global-set-key (kbd "s-<f10>") 'tool-bar-mode)

;; Restart Emacs
(global-set-key (kbd "<f12>") 'restart-emacs)

;; Emacs frontend for weather web service wttr.in
(global-set-key (kbd "s-<f12>") 'wttrin)

(provide 'setup-key-bindings)
;;; setup-key-bindings.el ends here
