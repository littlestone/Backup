;;; setup-shell.el --- tweak Emacs shell settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Setup shell

;; Note: Emacs runs .bashrc in *shell*
;; So mac users should ln -s .profile .bashrc

;; C-d to kill buffer if process is dead.
(defun comint-delchar-or-eof-or-kill-buffer (arg)
  (interactive "p")
  (if (null (get-buffer-process (current-buffer)))
      (kill-buffer)
    (comint-delchar-or-maybe-eof arg)))

(add-hook 'shell-mode-hook
          (lambda ()
            (define-key shell-mode-map (kbd "C-d") 'comint-delchar-or-eof-or-kill-buffer)))

;; Auto close shell buffer when exits
(defun wcy-shell-mode-hook-func  ()
  (set-process-sentinel (get-buffer-process (current-buffer))
                        #'wcy-shell-mode-kill-buffer-on-exit))

(defun wcy-shell-mode-kill-buffer-on-exit (process state)
  (message "%s" state)
  (if (or
       (string-match "exited abnormally with code.*" state)
       (string-match "finished" state))
      (delete-window)))

(add-hook 'shell-mode-hook 'wcy-shell-mode-hook-func)

;; Strips away all ansi color codes in shells
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(provide 'setup-shell)
;;; setup-shell.el ends here
