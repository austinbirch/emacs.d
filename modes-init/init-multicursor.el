
; Setting up Multi-Cursor Mode
; New-line in multi-cursor-mode = C-j

; https://github.com/magnars/multiple-cursors.el/issues/19
; Now multiple-cursor-mode (entering it) will go into emacs mode
; so that all the emacs bindings work
(defvar my-mc-evil-previous-state nil)

(defun my-mc-evil-switch-to-insert-state ()
  (when (and (bound-and-true-p evil-mode)
             (not (memq evil-state '(insert emacs))))
    (setq my-mc-evil-previous-state evil-state)
    (evil-emacs-state 1)))

(defun my-mc-evil-back-to-previous-state ()
  (when my-mc-evil-previous-state
    (unwind-protect
        (case my-mc-evil-previous-state
          ((normal visual) (evil-force-normal-state))
          (t (message "Don't know how to handle previous state: %S"
                      my-mc-evil-previous-state)))
      (setq my-mc-evil-previous-state nil))))

(add-hook 'multiple-cursors-mode-enabled-hook
          'my-mc-evil-switch-to-insert-state)
(add-hook 'multiple-cursors-mode-disabled-hook
          'my-mc-evil-back-to-previous-state)

(defun my-rrm-evil-switch-state ()
  (if rectangular-region-mode
      (my-mc-evil-switch-to-insert-state)
    ;; (my-mc-evil-back-to-previous-state)  ; does not work...
    (setq my-mc-evil-previous-state nil)))

(add-hook 'rectangular-region-mode-hook 'my-rrm-evil-switch-state)

(provide 'init-multicursor)