;; title: tobeyapp
;; version: 0.1.0
;; summary: A simple example of a Clarinet contract
;; description: This contract is a simple example of a Clarinet contract

;; tobey-app

(define-data-var wish-counter uint u0)

(define-map wishes
    { id: uint }
    {
        creator: principal,
        wish: (string-ascii 50),
        fulfilled-by: (optional principal),
        status: (string-ascii 10),
    }
)

;; Share a new wish
(define-public (share-wish (wish (string-ascii 50)))
    (let ((id (var-get wish-counter)))
        (map-set wishes { id: id } {
            creator: tx-sender,
            wish: wish,
            fulfilled-by: none,
            status: "open",
        })
        (var-set wish-counter (+ id u1))
        (ok id)
    )
)

;; Fulfill an open wish
(define-public (fulfill-wish (id uint))
    (match (map-get? wishes { id: id })
        wish
        (if (is-eq (get status wish) "open")
            (begin
                (map-set wishes { id: id } {
                    creator: (get creator wish),
                    wish: (get wish wish),
                    fulfilled-by: (some tx-sender),
                    status: "fulfilled",
                })
                (ok "Wish fulfilled")
            )
            (err u1)
        )
        ;; not open
        (err u2)
    )
    ;; wish not found
)

;; Archive a fulfilled wish
(define-public (archive-wish (id uint))
    (match (map-get? wishes { id: id })
        wish
        (if (and (is-eq (get status wish) "fulfilled") (is-eq tx-sender (get creator wish)))
            (begin
                (map-set wishes { id: id } {
                    creator: (get creator wish),
                    wish: (get wish wish),
                    fulfilled-by: (get fulfilled-by wish),
                    status: "archived",
                })
                (ok "Wish archived")
            )
            (err u3)
        )
        ;; not fulfilled or not creator
        (err u4)
    )
    ;; wish not found
)