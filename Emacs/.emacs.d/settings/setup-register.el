;;; setup-register.el --- Emacs register settings -*- lexical-binding: t; -*-

;;; Commentary:

;; Registers allow you to jump to a file or other location quickly.
;; To jump to a register, use =C-x r j= followed by the letter of
;; the register.  Using registers for all these file shortcuts is
;; probably a bit of a waste since I can easily define m/y own
;; keymap, but since I rarely go beyond register A anyway... -- Sacha Chua

;;; Code:

(mapc
 (lambda (r)
   (set-register (car r) (cons 'file (cdr r))))
 '((?b . "~/org-files/blog.org")
   (?l . "~/org-files/life.org")
   (?t . "~/org-files/todo.org")
   (?n . "~/org-files/note.org")
   (?w . "~/org-files/work.org")
   (?e . "~/org-files/emacs.org")
   (?j . "~/org-files/journal.org")
   (?f . "~/org-files/freedom.org")
   (?r . "~/org-files/reading.org")
   (?c . "~/org-files/calendar.org")
   (?u . "~/org-files/plantuml.org")
   (?g . "~/org-files/tang-junjie.github.io/index.org")))

(provide 'setup-register)
;;; setup-register.el ends here
