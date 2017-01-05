;;; setup-org.el --- Organize Your Life in Plain Text! -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'org)

;; org-mode colors
(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "DodgerBlue" :weight bold))
        ("NEXT" . (:foreground "red" :weight bold))
        ("INPR" . (:foreground "chocolate1" :weight bold))
        ("DONE" . (:foreground "green" :weight bold))
        ("WAITING" . (:foreground "yellow" :weight bold))
        ("SOMEDAY" . (:foreground "wheat4" :weight bold))
        ("CANCELLED" . (:foreground "magenta" :weight bold))))

(defun myorg-update-parent-cookie ()
  (when (equal major-mode 'org-mode)
    (save-excursion
      (ignore-errors
        (org-back-to-heading)
        (org-update-parent-todo-statistics)))))

(defadvice org-kill-line (after fix-cookies activate)
  (myorg-update-parent-cookie))

(defadvice kill-whole-line (after fix-cookies activate)
  (myorg-update-parent-cookie))

(setq org-directory "~/org-files")
(setq org-default-notes-file (concat org-directory "/note.org"))
(setq org-plantuml-jar-path (expand-file-name "plantuml.jar" org-directory))

;; Standard key bindings
(define-key org-mode-map (kbd "C-c a") 'org-agenda)
(define-key org-mode-map (kbd "C-c c") 'org-capture)
(define-key org-mode-map (kbd "C-c b") 'org-iswitchb)
(define-key org-mode-map (kbd "C-c l") 'org-store-link)

;; Don't ruin S-arrow to switch windows please (use M-+ and M-- instead to toggle)
(setq org-replace-disputed-keys t)

;; Fontify org-mode code blocks
(setq org-src-fontify-natively t)

;; Allow alphabetical org list
(setq org-list-allow-alphabetical t)

;; Calenda/Diary integration
(setq org-agenda-include-diary t)

;; Task dependencies
(setq org-enforce-todo-dependencies t)
(setq org-track-ordered-property-with-tag t)
(setq org-agenda-dim-blocked-tasks t)

;; Insert org log into drawer
(setq org-log-into-drawer t)

;; Active Org-babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '(;; other Babel languages
   (ditaa . t)
   (plantuml . t)))

;; Org agenda
(setq org-agenda-files
      (delq nil
            (mapcar (lambda (x) (and (file-exists-p x) x))
                    '("~/org-files/blog.org"
                      "~/org-files/life.org"
                      "~/org-files/todo.org"
                      "~/org-files/note.org"
                      "~/org-files/work.org"
                      "~/org-files/emacs.org"
                      "~/org-files/journal.org"
                      "~/org-files/freedom.org"
                      "~/org-files/reading.org"
                      "~/org-files/calendar.org"
                      "~/org-files/plantuml.org"
                      "~/org-files/tang-junjie.github.io/index.org"))))
(add-to-list 'auto-mode-alist '("\\.txt$" . org-mode))

;; Disable cua-mode
(add-hook 'org-mode-hook (lambda () (cua-mode -1)))

(provide 'setup-org)
;;; setup-org.el ends here
