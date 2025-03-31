;; Constants
(define-constant VAULT_CAPACITY u1000000)
(define-constant BASE_CONTRIBUTION_REWARD u10)
(define-constant CONSISTENCY_BONUS u2)
(define-constant MAX_CONSISTENCY_LEVEL u7)
(define-constant ERR_INVALID_CONTRIBUTION u1)
(define-constant ERR_NO_POINTS u2)
(define-constant ERR_CAPACITY_EXCEEDED u3)
(define-constant BLOCKS_PER_DAY u144)
(define-constant LOCK_MULTIPLIER u2)
(define-constant MIN_LOCK_DURATION u288)
(define-constant EARLY_UNLOCK_PENALTY u10)

;; Data Variables
(define-data-var total-points-issued uint u0)
(define-data-var total-contributions uint u0)
(define-data-var vault-admin principal tx-sender)

;; Data Maps
(define-map contributor-submissions principal uint)
(define-map contributor-points principal uint)
(define-map contribution-start-time principal uint)
(define-map contributor-consistency principal uint)
(define-map contributor-last-activity principal uint)
(define-map contributor-locked-points principal uint)
(define-map contributor-lock-start-block principal uint)

;; Public Functions

(define-public (start-contribution (effort uint))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (> effort u0) (err ERR_INVALID_CONTRIBUTION))
    (map-set contribution-start-time caller burn-block-height)
    (ok true)
  )
)

(define-public (complete-contribution (effort uint))
  (let
    (
      (caller tx-sender)
      (start-block (default-to u0 (map-get? contribution-start-time caller)))
      (blocks-passed (- burn-block-height start-block))
      (last-activity-block (default-to u0 (map-get? contributor-last-activity caller)))
      (consistency-level (default-to u0 (map-get? contributor-consistency caller)))
      (capped-consistency (if (<= consistency-level MAX_CONSISTENCY_LEVEL) consistency-level MAX_CONSISTENCY_LEVEL))
      (reward-amount (+ BASE_CONTRIBUTION_REWARD (* capped-consistency CONSISTENCY_BONUS)))
    )
    (asserts! (and (> start-block u0) (>= blocks-passed effort)) (err ERR_INVALID_CONTRIBUTION))
    (map-set contributor-submissions caller (+ (default-to u0 (map-get? contributor-submissions caller)) u1))
    (map-set contributor-points caller (+ (default-to u0 (map-get? contributor-points caller)) reward-amount))
    (if (< (- burn-block-height last-activity-block) BLOCKS_PER_DAY)
      (map-set contributor-consistency caller (+ consistency-level u1))
      (map-set contributor-consistency caller u1)
    )
    (map-set contributor-last-activity caller burn-block-height)
    (var-set total-contributions (+ (var-get total-contributions) u1))
    (var-set total-points-issued (+ (var-get total-points-issued) reward-amount))
    (asserts! (<= (var-get total-points-issued) VAULT_CAPACITY) (err ERR_CAPACITY_EXCEEDED))
    (ok reward-amount)
  )
)

(define-public (redeem-points)
  (let
    (
      (caller tx-sender)
      (point-balance (default-to u0 (map-get? contributor-points caller)))
    )
    (asserts! (> point-balance u0) (err ERR_NO_POINTS))
    (map-set contributor-points caller u0)
    (ok point-balance)
  )
)

;; Locking Features

(define-public (lock-points (amount uint))
  (let
    (
      (caller tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_CONTRIBUTION))
    (asserts! (>= (var-get total-points-issued) amount) (err ERR_CAPACITY_EXCEEDED))
    (map-set contributor-locked-points caller amount)
    (map-set contributor-lock-start-block caller burn-block-height)
    (var-set total-points-issued (- (var-get total-points-issued) amount))
    (ok amount)
  )
)

(define-public (unlock-points)
  (let
    (
      (caller tx-sender)
      (locked-amount (default-to u0 (map-get? contributor-locked-points caller)))
      (lock-start-block (default-to u0 (map-get? contributor-lock-start-block caller)))
      (blocks-locked (- burn-block-height lock-start-block))
      (penalty (if (< blocks-locked MIN_LOCK_DURATION) (/ (* locked-amount EARLY_UNLOCK_PENALTY) u100) u0))
      (final-amount (- locked-amount penalty))
    )
    (asserts! (> locked-amount u0) (err ERR_NO_POINTS))
    (map-set contributor-locked-points caller u0)
    (map-set contributor-lock-start-block caller u0)
    (var-set total-points-issued (+ (var-get total-points-issued) final-amount))
    (ok final-amount)
  )
)

;; Read-Only Functions

(define-read-only (get-contribution-count (user principal))
  (default-to u0 (map-get? contributor-submissions user))
)

(define-read-only (get-point-balance (user principal))
  (default-to u0 (map-get? contributor-points user))
)

(define-read-only (get-consistency-level (user principal))
  (default-to u0 (map-get? contributor-consistency user))
)

(define-read-only (get-vault-stats)
  {
    total-contributions: (var-get total-contributions),
    total-points-issued: (var-get total-points-issued)
  }
)

;; Private Functions

(define-private (is-vault-admin)
  (is-eq tx-sender (var-get vault-admin))
)