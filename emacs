(if (>= emacs-major-version 24)
    (load-file "~/.emacs.d/init.el")
  (progn
    (message "Warn: Emacs is too old(<24) , skip loading ~/.emacs.d/init.el")
    ;; No backup file
    (setq make-backup-files nil)))
