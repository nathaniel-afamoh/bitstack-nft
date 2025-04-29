;; Title: BitStack NFT Protocol
;;
;; Summary:
;; A comprehensive NFT platform built on Stacks with collateralized assets, marketplace
;; functionality, fractional ownership, and staking rewards - all secured by Bitcoin.
;;
;; Description:
;; This smart contract implements a next-generation NFT protocol that enables users to:
;; - Mint NFTs with STX collateral backing
;; - Trade NFTs on an integrated marketplace with low protocol fees
;; - Fractionalize ownership to increase liquidity
;; - Earn yield through NFT staking
;; All operations are settled with finality on Bitcoin through the Stacks Layer 2 architecture.

;; Constants & Error Codes

(define-constant contract-owner tx-sender)

;; Access Control
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

;; Financial
(define-constant err-insufficient-balance (err u102))
(define-constant err-insufficient-collateral (err u106))

;; NFT Operations
(define-constant err-invalid-token (err u103))
(define-constant err-listing-not-found (err u104))
(define-constant err-invalid-price (err u105))

;; Staking
(define-constant err-already-staked (err u107))
(define-constant err-not-staked (err u108))

;; Validation
(define-constant err-invalid-percentage (err u109))
(define-constant err-invalid-uri (err u110))
(define-constant err-invalid-recipient (err u111))
(define-constant err-overflow (err u112))

;; Protocol Configuration

(define-data-var min-collateral-ratio uint u150)  ;; 150% minimum collateral ratio
(define-data-var protocol-fee uint u25)           ;; 2.5% fee in basis points
(define-data-var total-staked uint u0)
(define-data-var yield-rate uint u50)             ;; 5% annual yield rate in basis points
(define-data-var total-supply uint u0)

;; Data Maps

;; Core NFT Data
(define-map tokens
    { token-id: uint }
    {
        owner: principal,
        uri: (string-ascii 256),
        collateral: uint,
        is-staked: bool,
        stake-timestamp: uint,
        fractional-shares: uint
    }
)

;; Marketplace Listings
(define-map token-listings
    { token-id: uint }
    {
        price: uint,
        seller: principal,
        active: bool
    }
)

;; Fractional Ownership Records
(define-map fractional-ownership
    { token-id: uint, owner: principal }
    { shares: uint }
)

;; Staking Rewards Tracking
(define-map staking-rewards
    { token-id: uint }
    { 
        accumulated-yield: uint,
        last-claim: uint
    }
)

;; Private Helper Functions

(define-private (validate-uri (uri (string-ascii 256)))
    (let
        (
            (uri-len (len uri))
        )
        (and
            (> uri-len u0)
            (<= uri-len u256)
        )
    )
)

(define-private (validate-recipient (recipient principal))
    (not (is-eq recipient (as-contract tx-sender)))
)

(define-private (safe-add (a uint) (b uint))
    (let
        (
            (sum (+ a b))
        )
        (asserts! (>= sum a) err-overflow)
        (ok sum)
    )
)

;; Core NFT Functions

(define-public (mint-nft (uri (string-ascii 256)) (collateral uint))
    (let
        (
            (token-id (+ (var-get total-supply) u1))
            (collateral-requirement (/ (* (var-get min-collateral-ratio) collateral) u100))
        )
        (asserts! (validate-uri uri) err-invalid-uri)
        (asserts! (>= (stx-get-balance tx-sender) collateral-requirement) err-insufficient-collateral)
        (try! (stx-transfer? collateral-requirement tx-sender (as-contract tx-sender)))
        (map-set tokens
            { token-id: token-id }
            {
                owner: tx-sender,
                uri: uri,
                collateral: collateral,
                is-staked: false,
                stake-timestamp: u0,
                fractional-shares: u0
            }
        )
        (var-set total-supply token-id)
        (ok token-id)
    )
)

(define-public (transfer-nft (token-id uint) (recipient principal))
    (let
        (
            (token (unwrap! (get-token-info token-id) err-invalid-token))
        )
        (asserts! (validate-recipient recipient) err-invalid-recipient)
        (asserts! (is-eq tx-sender (get owner token)) err-not-token-owner)
        (asserts! (not (get is-staked token)) err-already-staked)
        (map-set tokens
            { token-id: token-id }
            (merge token { owner: recipient })
        )
        (ok true)
    )
)