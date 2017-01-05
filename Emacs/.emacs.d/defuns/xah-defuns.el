;;; xah-defuns.el --- Xah Lee's Emacs Lisp Functions -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(defun select-current-line ()
  "Select the current line"
  (interactive)
  (end-of-line) ; move to end of line
  (set-mark (line-beginning-position)))

(defun xah-open-in-external-app ()
  "Open the current file or dired marked files in external app.
The app is chosen from your OS's preference.

URL `http://ergoemacs.org/emacs/emacs_dired_open_file_in_ext_apps.html'
Version 2015-01-26"
  (interactive)
  (let* ((ξfile-list
          (if (string-equal major-mode "dired-mode")
              (dired-get-marked-files)
            (list (buffer-file-name))))
         (ξdo-it-p (if (<= (length ξfile-list) 5)
                       t
                     (y-or-n-p "Open more than 5 files? "))))
    (when ξdo-it-p
      (cond
       ((string-equal system-type "windows-nt")
        (mapc
         (lambda (fPath)
           (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" fPath t t))) ξfile-list))
       ((string-equal system-type "darwin")
        (mapc
         (lambda (fPath) (shell-command (format "open \"%s\"" fPath)))  ξfile-list))
       ((string-equal system-type "gnu/linux")
        (mapc
         (lambda (fPath) (let ((process-connection-type nil)) (start-process "" nil "xdg-open" fPath))) ξfile-list))))))

(defun xah-open-in-desktop ()
  "Show current file in desktop (OS's file manager).
URL `http://ergoemacs.org/emacs/emacs_dired_open_file_in_ext_apps.html'
Version 2015-11-30"
  (interactive)
  (cond
   ((string-equal system-type "windows-nt")
    (w32-shell-execute "explore" (replace-regexp-in-string "/" "\\" default-directory t t)))
   ((string-equal system-type "darwin") (shell-command "open ."))
   ((string-equal system-type "gnu/linux")
    (let (
          (process-connection-type nil)
          (openFileProgram (if (file-exists-p "/usr/bin/gvfs-open")
                               "/usr/bin/gvfs-open"
                             "/usr/bin/xdg-open")))
      (start-process "" nil openFileProgram "."))
    ;; (shell-command "xdg-open .") ;; 2013-02-10 this sometimes froze emacs till the folder is closed. ⁖ with nautilus
    )))

(defun xah-dired-rename-space-to-underscore ()
  "In dired, rename current or marked files by replacing space to underscore _.
If not in `dired', do nothing.

URL `http://ergoemacs.org/emacs/elisp_dired_rename_space_to_underscore.html'
Version 2016-10-04"
  (interactive)
  (if (equal major-mode 'dired-mode)
      (progn
        (mapc (lambda (x)
                (rename-file x (replace-regexp-in-string " " "_" x)))
              (dired-get-marked-files ))
        (revert-buffer))
    (user-error "Not in dired")))

(defun xah-dired-rename-space-to-hyphen ()
  "In dired, rename current or marked files by replacing space to hyphen -.
If not in `dired', do nothing.

URL `http://ergoemacs.org/emacs/elisp_dired_rename_space_to_underscore.html'
Version 2016-10-04"
  (interactive)
  (if (equal major-mode 'dired-mode)
      (progn
        (mapc (lambda (x)
                (rename-file x (replace-regexp-in-string " " "-" x)))
              (dired-get-marked-files ))
        (revert-buffer))
    (user-error "Not in dired")))

(defun xah-insert-date ()
  "Insert current date and or time.
Insert date in this format: yyyy-mm-dd.
When called with `universal-argument', prompt for a format to use.
If there's text selection, delete it first.

Do not use this function in lisp code. Call `format-time-string' directly.

URL `http://ergoemacs.org/emacs/elisp_insert-date-time.html'
version 2016-10-11"
  (interactive)
  (when (use-region-p) (delete-region (region-beginning) (region-end)))
  (let ((-style
         (if current-prefix-arg
             (string-to-number
              (substring
               (ido-completing-read
                "Style:"
                '(
                  "1 → 2016-10-10 Monday"
                  "2 → 2016-10-10T19:39:47-07:00"
                  "3 → 2016-10-10 19:39:58-07:00"
                  "4 → Monday, October 10, 2016"
                  "5 → Mon, Oct 10, 2016"
                  "6 → October 10, 2016"
                  "7 → Oct 10, 2016"
                  )) 0 1))
           0
           )))
    (insert
     (cond
      ((= -style 0)
       (format-time-string "%Y-%m-%d") ; "2016-10-10"
       )
      ((= -style 1)
       (format-time-string "%Y-%m-%d %A") ; "2016-10-10 Monday"
       )
      ((= -style 2)
       (concat
        (format-time-string "%Y-%m-%dT%T")
        ((lambda (-x) (format "%s:%s" (substring -x 0 3) (substring -x 3 5))) (format-time-string "%z")))
       ;; "2016-10-10T19:02:23-07:00"
       )
      ((= -style 3)
       (concat
        (format-time-string "%Y-%m-%d %T")
        ((lambda (-x) (format "%s:%s" (substring -x 0 3) (substring -x 3 5))) (format-time-string "%z")))
       ;; "2016-10-10 19:10:09-07:00"
       )
      ((= -style 4)
       (format-time-string "%A, %B %d, %Y")
       ;; "Monday, October 10, 2016"
       )
      ((= -style 5)
       (format-time-string "%a, %b %d, %Y")
       ;; "Mon, Oct 10, 2016"
       )
      ((= -style 6)
       (format-time-string "%B %d, %Y")
       ;; "October 10, 2016"
       )
      ((= -style 7)
       (format-time-string "%b %d, %Y")
       ;; "Oct 10, 2016"
       )
      (t
       (format-time-string "%Y-%m-%d"))))))

(provide 'xah-defuns)
;;; xah-defuns.el ends here
