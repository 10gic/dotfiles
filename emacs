(if (version< emacs-version "24.4")
    (progn
      (message "Warn: Emacs is too old (<24.4) , skip loading ~/.emacs.d/init.el")
      ;; No backup file
      (setq make-backup-files nil))
  (load-file "~/.emacs.d/init.el"))
