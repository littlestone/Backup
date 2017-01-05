;;; emacser-defuns.el --- Emacs Lisp Hackers' Functions -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun mouse-start-rectangle (start-event)
  "Enable Emacs column selection using mouse.
URL `http://emacs.stackexchange.com/questions/7244/enable-emacs-column-selection-using-mouse'"
  (interactive "e")
  (deactivate-mark)
  (mouse-set-point start-event)
  (rectangle-mark-mode +1)
  (let ((drag-event))
    (track-mouse
      (while (progn
               (setq drag-event (read-event))
               (mouse-movement-p drag-event))
        (mouse-set-point drag-event)))))

(defun xml-pretty-print (begin end)
  "Pretty format XML markup in region.  You need to have `nxml-mode'
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    (while (search-forward-regexp "\>[ \\t]*\<" nil t)
      (backward-char) (insert "\n"))
    (indent-region begin end))
  (message "Ah, much better!"))

(defun frame-transparency (value)
  "Sets the transparency of the frame window. 0=transparent/100=opaque."
  (interactive "nTransparency Value 0 - 100 opaque:")
  (set-frame-parameter (selected-frame) 'alpha value))

(defun message-timestamp-on ()
  "Enable timestamp on the *Messages* buffer."
  (interactive)
  (defadvice message (before when-was-that activate)
    "Add timestamps to `message' output."
    (ad-set-arg 0 (concat (current-time-microseconds)
                          (ad-get-arg 0)))))

(defun message-timestamp-off ()
  "Disable timestamp on the *Messages* buffer."
  (interactive)
  (ad-disable-advice 'message 'before 'when-was-that)
  (ad-update 'message))

(defmacro measure-time (&rest body)
  "Measure the time it takes to evaluate BODY."
  `(let ((time (current-time)))
     ,@body
     (message "%.06f" (float-time (time-since time)))))

(defun joaot/delete-process-at-point ()
  (interactive)
  (let ((process (get-text-property (point) 'tabulated-list-id)))
    (cond ((and process
                (processp process))
           (delete-process process)
           (revert-buffer))
          (t
           (error "no process at point!")))))

(provide 'emacser-defuns)
;;; emacser-defuns.el ends here
