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