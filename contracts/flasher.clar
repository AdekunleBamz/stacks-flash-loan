(use-trait ft-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)
(use-trait stx-flasher .flashloans-trait.stx-flasher)
(use-trait sip010-flasher .flashloans-trait.sip010-flasher)

(define-constant THIS_CONTRACT (as-contract tx-sender))
(define-constant STX_FLASH_FEES_PIPS u5000) ;; 5000 pips = 0.5% interest
(define-constant SIP010_FLASH_FEES_PIPS u10000) ;; 10000 pips = 1% interest

(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_OUTBOUND_TRANFER_FAILED (err u102))
(define-constant ERR_FLASHER_CALLBACK_FAILED (err u103))
(define-constant ERR_INBOUND_TRANFER_FAILED (err u104))
(define-constant ERR_INSUFFICIENT_PAYBACK (err u105))
(define-constant ERR_FAILED_TO_FETCH_BALANCE (err u106))

;; Flash a STX amount to a recipient contract that implements the stx-flasher trait
;; Verifies that it gets paid back the amount plus interest by the end of the call
;; Reverts the transaction if the recipient contract fails to pay back the amount plus interest
;; Flash a STX amount to a recipient contract that implements the stx-flasher trait
;; Verifies that it gets paid back the amount plus interest by the end of the call
;; Reverts the transaction if the recipient contract fails to pay back the amount plus interest
(define-public (flash-stx
        (amount uint)
        (recipient <stx-flasher>)
    )
    (let (
            ;; Keep track of the original balance of STX in this contract
            (original-stx-balance (stx-get-balance THIS_CONTRACT))
            ;; Calculate the total return amount including interest fees
            (return-amount (get-return-amount amount STX_FLASH_FEES_PIPS))
            ;; Calculate the interest amount
            (interest-amount (- return-amount amount))
            ;; Calculate the final STX balance we SHOULD have after the flash loan
            (expected-final-stx-balance (+ original-stx-balance interest-amount))
        )
        ;; Ensure we have enough STX to even do the flash loan
        (asserts! (>= original-stx-balance amount) ERR_INSUFFICIENT_BALANCE)

        ;; Send STX to the receiver contract
        (unwrap!
            (as-contract (stx-transfer? amount THIS_CONTRACT (contract-of recipient)))
            ERR_OUTBOUND_TRANFER_FAILED
        )

        ;; Call the receiver contract's on-stx-flash function
        (unwrap! (contract-call? recipient on-stx-flash amount return-amount)
            ERR_FLASHER_CALLBACK_FAILED
        )

        ;; Check that the receiver contract paid back the amount plus interest
        (asserts! (>= (stx-get-balance THIS_CONTRACT) expected-final-stx-balance)
            ERR_INSUFFICIENT_PAYBACK
        )
        (ok true)
    )
)

;; Flash a SIP010 token amount to a recipient contract that implements the sip010-flasher trait
;; Verifies that it gets paid back the amount plus interest by the end of the call
;; Reverts the transaction if the recipient contract fails to pay back the amount plus interest
;; Flash a SIP010 token amount to a recipient contract that implements the sip010-flasher trait
;; Verifies that it gets paid back the amount plus interest by the end of the call
;; Reverts the transaction if the recipient contract fails to pay back the amount plus interest
(define-public (flash-sip010
        (token <ft-trait>)
        (amount uint)
        (recipient <sip010-flasher>)
    )
    (let (
            ;; Keep track of the original balance of the token in this contract
            (original-token-balance (unwrap! (contract-call? token get-balance THIS_CONTRACT)
                ERR_FAILED_TO_FETCH_BALANCE
            ))
            ;; Calculate the total return amount including interest fees
            (return-amount (get-return-amount amount SIP010_FLASH_FEES_PIPS))
            ;; Calculate the interest amount
            (interest-amount (- return-amount amount))
            ;; Calculate the final token balance we SHOULD have after the flash loan
            (expected-final-token-balance (+ original-token-balance interest-amount))
        )
        (asserts! (>= original-token-balance amount) ERR_INSUFFICIENT_BALANCE)
        (unwrap!
            (as-contract (contract-call? token transfer amount THIS_CONTRACT
                (contract-of recipient) none
            ))
            ERR_OUTBOUND_TRANFER_FAILED
        )
        (unwrap!
            (contract-call? recipient on-sip010-flash token amount return-amount)
            ERR_FLASHER_CALLBACK_FAILED
        )
        (asserts!
            (>=
                (unwrap!
                    (as-contract (contract-call? token get-balance THIS_CONTRACT))
                    ERR_FAILED_TO_FETCH_BALANCE
                )
                expected-final-token-balance
            )
            ERR_INSUFFICIENT_PAYBACK
        )
        (ok true)
    )
)

;; Given an amount and interest fees being charged, calculates the return amount
;; Given an amount and interest fees being charged, calculates the return amount
(define-private (get-return-amount
        (amount uint)
        (fees-pips uint)
    )
    (let (
            (interest (/ (* amount fees-pips) u1000000))
            (return-amount (+ amount interest))
        )
        return-amount
    )
)
