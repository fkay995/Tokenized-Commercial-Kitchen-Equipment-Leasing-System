;; Asset Registration Contract
;; Records details of food service equipment

(define-data-var last-asset-id uint u0)

;; Asset structure: id, name, type, value, condition, owner
(define-map assets
  { asset-id: uint }
  {
    name: (string-ascii 100),
    type: (string-ascii 50),
    value: uint,
    condition: (string-ascii 20),
    owner: principal,
    is-available: bool
  }
)

;; Register a new asset
(define-public (register-asset (name (string-ascii 100)) (type (string-ascii 50)) (value uint) (condition (string-ascii 20)))
  (let
    (
      (new-id (+ (var-get last-asset-id) u1))
    )
    (asserts! (is-eq tx-sender contract-caller) (err u403))
    (var-set last-asset-id new-id)
    (map-set assets
      { asset-id: new-id }
      {
        name: name,
        type: type,
        value: value,
        condition: condition,
        owner: tx-sender,
        is-available: true
      }
    )
    (ok new-id)
  )
)

;; Update asset details
(define-public (update-asset (asset-id uint) (name (string-ascii 100)) (type (string-ascii 50)) (value uint) (condition (string-ascii 20)) (is-available bool))
  (let
    (
      (asset (unwrap! (map-get? assets { asset-id: asset-id }) (err u404)))
    )
    (asserts! (is-eq (get owner asset) tx-sender) (err u403))
    (map-set assets
      { asset-id: asset-id }
      {
        name: name,
        type: type,
        value: value,
        condition: condition,
        owner: tx-sender,
        is-available: is-available
      }
    )
    (ok true)
  )
)

;; Get asset details
(define-read-only (get-asset (asset-id uint))
  (map-get? assets { asset-id: asset-id })
)

;; Check if asset is available for lease
(define-read-only (is-asset-available (asset-id uint))
  (match (map-get? assets { asset-id: asset-id })
    asset (get is-available asset)
    false
  )
)

;; Update asset availability
(define-public (set-asset-availability (asset-id uint) (available bool))
  (let
    (
      (asset (unwrap! (map-get? assets { asset-id: asset-id }) (err u404)))
    )
    (asserts! (is-eq (get owner asset) tx-sender) (err u403))
    (map-set assets
      { asset-id: asset-id }
      (merge asset { is-available: available })
    )
    (ok true)
  )
)
