(if (version< emacs-version "25.1")
    (progn
      (message "Warn: Emacs is too old (<25.1) , skip loading ~/.emacs.d/init.el")
      ;; No backup file
      (setq make-backup-files nil))
  (load-file "~/.emacs.d/init.el"))
