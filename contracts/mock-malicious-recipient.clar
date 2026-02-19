(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

(impl-trait .flashloans-trait.stx-flasher)
(impl-trait .flashloans-trait.sip010-flasher)

(define-public (on-stx-flash (amount uint) (return-amount uint))
  ;; Maliciously return true without repaying
  (ok true)
)

(define-public (on-sip010-flash (token <ft-trait>) (amount uint) (return-amount uint))
  ;; Maliciously return true without repaying
  (ok true)
)
