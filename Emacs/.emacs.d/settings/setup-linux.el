;;; setup-linux.el --- Emacs linux environment settings -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Ignore .DS_Store files with ido mode
(add-to-list 'ido-ignore-files "\\.DS_Store")

;; Use aspell for spell checking: brew install aspell --lang=en
(setq ispell-program-name "/usr/bin/aspell")

(provide 'setup-linux)
;;; setup-linux.el ends here
