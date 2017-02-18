;;; setup-package.el --- tweak Emacs package settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'package)

;; Add package sources
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("org" . "http://orgmode.org/elpa/")
        ("melpa" . "http://melpa.org/packages/")))

(package-initialize)
(unless (file-exists-p "~/.emacs.d/elpa/archives/melpa")
  (package-refresh-contents))

;; Require dash --- the modern list library for Emacs
(if (not (package-installed-p 'dash))
    (progn
      (package-refresh-contents)
      (package-install 'dash)))
(require 'dash)

;; Font lock dash.el
(eval-after-load "dash" '(dash-enable-font-lock))

;;; On-demand installation of packages

(defun packages-install (packages)
  (--each packages
    (when (not (package-installed-p it))
      (package-install it)))
  (delete-other-windows))

(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (package-install package)
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))

;; Install extensions if they're missing
(defun init--install-packages ()
  (packages-install
   '(0xc                                ; Base conversion made easy
     2048-game                          ; play 2048 in Emacs
     ace-jump-mode                      ; a quick cursor location minor mode for emacs
     ace-mc                             ; Add multiple cursors quickly using ace jump
     ascii                              ; ASCII code display.
     aggressive-indent                  ; Minor mode to aggressively keep your code always indented
     anaconda-mode                      ; Code navigation, documentation lookup and completion for Python
     buffer-flip                        ; Use key-chord to cycle through buffers like Alt-Tab in Windows
     browse-kill-ring                   ; interactively insert items from kill-ring
     buffer-move                        ; easily swap buffers
     charmap                            ; Unicode table for Emacs
     company                            ; Modular text completion framework
     csharp-mode                        ; C# mode derived mode
     darkokai-theme                     ; A darker variant on Monokai.
     disaster                           ; Disassemble C/C++ code under cursor in Emacs
     dired-details                      ; make file details hide-able in dired
     dired-single                       ; Reuse the current dired buffer to visit another directory
     ein                                ; Emacs IPython Notebook
     elisp-format                       ; Format elisp code
     elisp-lint                         ; basic linting for Emacs Lisp
     elmacro                            ; Convert keyboard macros to elisp
     elpy                               ; Emacs Python Development Environment
     evil                               ; Extensible Vi layer for Emacs.
     evil-numbers                       ; increment/decrement numbers like in vim
     evil-vimish-fold                   ; Integrate vimish-fold with evil
     expand-region                      ; Increase selected region by semantic units.
     fill-column-indicator              ; Graphically indicate the fill column
     find-file-in-project               ; Find files in a project quickly, on any OS
     flx-ido                            ; flx integration for ido
     flycheck                           ; On-the-fly syntax checking
     focus                              ; Dim the font color of text in surrounding sections
     fold-this                          ; Just fold this region please
     frame-cmds                         ; Frame and window commands (interactive functions).
     frame-fns                          ; Non-interactive frame and window functions
     git-gutter-fringe                  ; Fringe version of git-gutter.el
     git-timemachine                    ; Walk through git revisions of a file
     golden-ratio                       ; Automatic resizing of Emacs windows to the golden ratio
     google-this                        ; A set of functions and bindings to google under point.
     google-translate                   ; Emacs interface to Google Translate.
     heap                               ; Heap (a.k.a. priority queue) data structure
     highlight-escape-sequences         ; Highlight escape sequences
     highlight-indent-guides            ; Minor mode to highlight indentation
     ido-at-point                       ; ido-style completion-at-point
     ido-hacks                          ; Put more IDO in your IDO
     ido-ubiquitous                     ; Use ido (nearly) everywhere.
     ido-vertical-mode                  ; Makes ido-mode display vertically.
     iedit                              ; Edit multiple regions in the same way simultaneously.
     image-dired+                       ; Image-dired extensions
     imenu-anywhere                     ; ido/helm imenu tag selection across all buffers with the same mode
     impatient-mode                     ; Serve buffers live over HTTP
     info+                              ; Extensions to `info.el'.
     js2-mode                           ; Improved JavaScript editing mode
     json-mode                          ; Major mode for editing JSON files
     key-chord                          ; key-chord binding helper for use-package-chords
     litable                            ; dynamic evaluation replacement with emacs
     linum-relative                     ; display relative line number in emacs.
     live-py-mode                       ; Live Coding in Python
     macrostep                          ; interactive macro expander
     magit                              ; A Git porcelain inside Emacs
     markdown-mode                      ; Emacs Major mode for Markdown-formatted text files
     minimap                            ; Sidebar showing a "mini-map" of a buffer
     monokai-theme                      ; A fruity color theme for Emacs.
     multifiles                         ; View and edit parts of multiple files in one buffer
     multiple-cursors                   ; Multiple cursors for Emacs.
     neotree                            ; A tree plugin like NerdTree for Vim
     nyan-mode                          ; Nyan Cat shows position in current buffer in mode-line.
     nyan-prompt                        ; Nyan Cat on the eshell prompt.
     ob-http                            ; http request in org-mode babel
     ob-ipython                         ; org-babel functions for IPython evaluation
     org                                ; Outline-based notes management and organizer
     paredit                            ; minor mode for editing parentheses
     paren-face                         ; a face for parentheses in lisp modes
     persistent-scratch                 ; Preserve the scratch buffer across Emacs sessions
     planet-theme                       ; A dark theme inspired by Gmail's 'Planets' theme of yore
     powerline                          ; Rewrite of Powerline
     projectile                         ; Manage and navigate projects in Emacs easily
     py-autopep8                        ; Use autopep8 to beautify a Python buffer
     py-yapf                            ; Use yapf to beautify a Python buffer
     pygen                              ; Python code generation using Elpy and Python-mode.
     pylint                             ; minor mode for running `pylint'
     pyimport                           ; Manage Python imports!
     pytest                             ; Easy Python test running in Emacs
     queue                              ; Queue data structure
     rainbow-mode                       ; Colorize color names in buffers
     realgud                            ; A modular front-end for interacting with external debuggers
     restart-emacs                      ; Restart emacs from within emacs
     s                                  ; The long lost Emacs string manipulation library.
     skewer-mode                        ; live browser JavaScript, CSS, and HTML interaction
     slime                              ; Superior Lisp Interaction Mode for Emacs
     smart-compile                      ; an interface to `compile'
     smex                               ; M-x interface with Ido-style fuzzy matching.
     solarized-theme                    ; The Solarized color theme, ported to Emacs.
     suggest                            ; suggest elisp functions that give the output requested
     swiper                             ; Isearch with an overview. Oh, man!
     switch-window                      ; A *visual* way to choose a window to switch to
     tide                               ; Typescript Interactive Development Environment
     undo-tree                          ; Treat undo history as a tree
     use-package                        ; A use-package declaration for simplifying your .emacs
     vimish-fold                        ; Fold text like in Vim
     visual-regexp                      ; A regexp/replace command for Emacs with interactive visual feedback
     web-mode                           ; major mode for editing web templates
     wgrep                              ; Writable grep buffer and apply the changes to files
     which-key                          ; Display available keybindings in popup
     whitespace-cleanup-mode            ; Intelligently call whitespace-cleanup on save
     wttrin                             ; Emacs frontend for weather web service wttr.in
     xterm-color                        ; ANSI & xterm-256 color text property translator for Emacs
     yaml-mode                          ; Major mode for editing YAML files
     yasnippet                          ; Yet another snippet extension for Emacs.
     zoom-frm                           ; Commands to zoom frame font size.
     zzz-to-char                        ; Fancy version of `zap-to-char' command
     )))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

(provide 'setup-package)
;;; setup-package.el ends here
