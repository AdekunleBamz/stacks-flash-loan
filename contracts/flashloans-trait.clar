(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Receiver contract that can receive STX Flash Loans needs to implement this trait
(define-trait stx-flasher (
    (on-stx-flash
        ;; Arguments:
        ;; 1st: `amount` is the amount of STX to flash loan
        ;; 2nd: `return-amount` is the amount of STX to return to the flasher (amount + interest)
        (uint uint)
        (response bool uint)
    )
))

;; Receiver contract that can receive SIP010 Token Flash Loans needs to implement this trait
(define-trait sip010-flasher (
    (on-sip010-flash
        ;; Arguments:
        ;; 1st: `token-contract` is the contract address of the token to flash loan
        ;; 2nd: `amount` is the amount of the token to flash loan
        ;; 3rd: `return-amount` is the amount of the token to return to the flasher (amount + interest)
        (<ft-trait> uint uint)
        (response bool uint)
    )
))
