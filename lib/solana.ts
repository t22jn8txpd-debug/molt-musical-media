import { Connection, PublicKey, Transaction, SystemProgram, LAMPORTS_PER_SOL } from '@solana/web3.js'
import { getAssociatedTokenAddress, createTransferInstruction, TOKEN_PROGRAM_ID } from '@solana/spl-token'

// USDC Mint Address on Solana Mainnet
const USDC_MINT = new PublicKey('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v')

// Platform fee wallet (replace with actual wallet)
const PLATFORM_WALLET = new PublicKey('YOUR_PLATFORM_WALLET_ADDRESS_HERE')

// Platform fee percentage
const PLATFORM_FEE = 0.025 // 2.5%

export interface PaymentParams {
  from: PublicKey
  to: PublicKey
  amount: number // in USDC
  collaborators?: {
    address: PublicKey
    split: number // percentage (0-100)
  }[]
}

/**
 * Create a USDC payment transaction with automatic fee and split handling
 */
export async function createPaymentTransaction(
  connection: Connection,
  params: PaymentParams
): Promise<Transaction> {
  const transaction = new Transaction()

  const totalAmount = params.amount
  const platformFee = totalAmount * PLATFORM_FEE
  const remainingAmount = totalAmount - platformFee

  // Get associated token accounts
  const fromTokenAccount = await getAssociatedTokenAddress(
    USDC_MINT,
    params.from
  )

  const toTokenAccount = await getAssociatedTokenAddress(
    USDC_MINT,
    params.to
  )

  const platformTokenAccount = await getAssociatedTokenAddress(
    USDC_MINT,
    PLATFORM_WALLET
  )

  // Transfer platform fee
  transaction.add(
    createTransferInstruction(
      fromTokenAccount,
      platformTokenAccount,
      params.from,
      Math.floor(platformFee * 1_000_000) // USDC has 6 decimals
    )
  )

  // Handle collaborator splits if any
  if (params.collaborators && params.collaborators.length > 0) {
    for (const collab of params.collaborators) {
      const collabAmount = remainingAmount * (collab.split / 100)
      const collabTokenAccount = await getAssociatedTokenAddress(
        USDC_MINT,
        collab.address
      )

      transaction.add(
        createTransferInstruction(
          fromTokenAccount,
          collabTokenAccount,
          params.from,
          Math.floor(collabAmount * 1_000_000)
        )
      )
    }
  } else {
    // No collaborators - send all remaining to recipient
    transaction.add(
      createTransferInstruction(
        fromTokenAccount,
        toTokenAccount,
        params.from,
        Math.floor(remainingAmount * 1_000_000)
      )
    )
  }

  return transaction
}

/**
 * Get USDC balance for a wallet
 */
export async function getUSDCBalance(
  connection: Connection,
  wallet: PublicKey
): Promise<number> {
  try {
    const tokenAccount = await getAssociatedTokenAddress(
      USDC_MINT,
      wallet
    )

    const balance = await connection.getTokenAccountBalance(tokenAccount)
    return parseFloat(balance.value.uiAmount?.toString() || '0')
  } catch (error) {
    console.error('Error getting USDC balance:', error)
    return 0
  }
}

/**
 * Create an escrow transaction for gig payments
 */
export async function createEscrowTransaction(
  connection: Connection,
  client: PublicKey,
  amount: number
): Promise<Transaction> {
  // TODO: Implement escrow logic with Solana program
  // For MVP, this could be a simple transfer to a temporary escrow wallet
  // In production, use a proper escrow smart contract
  
  const transaction = new Transaction()
  
  // Placeholder - implement actual escrow logic
  console.log('Escrow transaction created for', amount, 'USDC')
  
  return transaction
}

/**
 * Calculate earnings after platform fee
 */
export function calculateEarnings(amount: number): {
  platformFee: number
  earnings: number
} {
  const platformFee = amount * PLATFORM_FEE
  const earnings = amount - platformFee
  
  return {
    platformFee: parseFloat(platformFee.toFixed(2)),
    earnings: parseFloat(earnings.toFixed(2))
  }
}

/**
 * Calculate revenue splits for collaborators
 */
export function calculateSplits(
  amount: number,
  collaborators: { split: number }[]
): {
  platformFee: number
  splits: number[]
} {
  const platformFee = amount * PLATFORM_FEE
  const remainingAmount = amount - platformFee
  
  const splits = collaborators.map(collab => {
    const split = remainingAmount * (collab.split / 100)
    return parseFloat(split.toFixed(2))
  })
  
  return {
    platformFee: parseFloat(platformFee.toFixed(2)),
    splits
  }
}

/**
 * Verify wallet connection
 */
export async function verifyWalletConnection(
  connection: Connection,
  wallet: PublicKey
): Promise<boolean> {
  try {
    const accountInfo = await connection.getAccountInfo(wallet)
    return accountInfo !== null
  } catch (error) {
    console.error('Error verifying wallet:', error)
    return false
  }
}

// Export constants for use in components
export { USDC_MINT, PLATFORM_FEE, PLATFORM_WALLET }
