;; Restaurant Verification Contract
;; Validates qualified business operators

(define-data-var last-restaurant-id uint u0)

;; Restaurant structure: id, name, address, license, verification status
(define-map restaurants
  { restaurant-id: uint }
  {
    name: (string-ascii 100),
    address: (string-ascii 200),
    license-number: (string-ascii 50),
    owner: principal,
    is-verified: bool
  }
)

;; Register a new restaurant
(define-public (register-restaurant (name (string-ascii 100)) (address (string-ascii 200)) (license-number (string-ascii 50)))
  (let
    (
      (new-id (+ (var-get last-restaurant-id) u1))
    )
    (var-set last-restaurant-id new-id)
    (map-set restaurants
      { restaurant-id: new-id }
      {
        name: name,
        address: address,
        license-number: license-number,
        owner: tx-sender,
        is-verified: false
      }
    )
    (ok new-id)
  )
)

;; Verify a restaurant (only contract owner can verify)
(define-public (verify-restaurant (restaurant-id uint) (verified bool))
  (let
    (
      (restaurant (unwrap! (map-get? restaurants { restaurant-id: restaurant-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender contract-caller) (err u403))
    (map-set restaurants
      { restaurant-id: restaurant-id }
      (merge restaurant { is-verified: verified })
    )
    (ok true)
  )
)

;; Get restaurant details
(define-read-only (get-restaurant (restaurant-id uint))
  (map-get? restaurants { restaurant-id: restaurant-id })
)

;; Check if restaurant is verified
(define-read-only (is-restaurant-verified (restaurant-id uint))
  (match (map-get? restaurants { restaurant-id: restaurant-id })
    restaurant (get is-verified restaurant)
    false
  )
)

;; Update restaurant details
(define-public (update-restaurant (restaurant-id uint) (name (string-ascii 100)) (address (string-ascii 200)) (license-number (string-ascii 50)))
  (let
    (
      (restaurant (unwrap! (map-get? restaurants { restaurant-id: restaurant-id }) (err u404)))
    )
    (asserts! (is-eq (get owner restaurant) tx-sender) (err u403))
    (map-set restaurants
      { restaurant-id: restaurant-id }
      (merge restaurant
        {
          name: name,
          address: address,
          license-number: license-number
        }
      )
    )
    (ok true)
  )
)
