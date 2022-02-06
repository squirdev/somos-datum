use anchor_lang::prelude::*;

declare_id!("AgxH9tmJsyVHiN7c6mMwkPh77dzgQxWQv1o1GgeSHFtN");

#[program]
pub mod somos_solana {
    use super::*;

    pub fn initialize_ledger(
        ctx: Context<InitializeLedger>,
        bump: u8,
    ) -> ProgramResult {
        let ledger = &mut ctx.accounts.ledger;
        ledger.original_supply_remaining = ConstantsImpl::TOTAL_SUPPLY;
        ledger.purchased = Vec::new();
        ledger.secondary_market = Vec::new();
        ledger.boss = ctx.accounts.user.key();
        ledger.bump = bump;
        Ok(())
    }

    pub fn purchase_primary(
        ctx: Context<PurchasePrimary>
    ) -> ProgramResult {
        let user = &mut ctx.accounts.user;
        let boss = &mut ctx.accounts.boss;
        let ledger = &mut ctx.accounts.ledger;
        let boss_pubkey = ledger.boss;
        Ledger::purchase_primary(
            user,
            boss,
            &boss_pubkey,
            ledger,
        )
    }
}

#[derive(Accounts)]
pub struct PurchasePrimary<'info> {
    #[account(mut)]
    pub user: Signer<'info>,
    #[account(mut)]
    // used to validate against persisted boss
    pub boss: AccountInfo<'info>,
    #[account(mut, seeds = [b"hancock".as_ref()], bump = ledger.bump)]
    pub ledger: Account<'info, Ledger>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(bump: u8)]
pub struct InitializeLedger<'info> {
    #[account(init, seeds = [b"hancock".as_ref()], bump = bump, payer = user, space = 10240)]
    pub ledger: Account<'info, Ledger>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct Ledger {
    pub original_supply_remaining: u16,
    pub purchased: Vec<Pubkey>,
    pub secondary_market: Vec<Pubkey>,
    // persist boss for validation
    pub boss: Pubkey,
    pub bump: u8,
}

#[error]
pub enum LedgerErrors {
    #[msg("we've already sold-out. check the secondary market.")]
    SoldOut,
    #[msg("you can only pay the boss for this track.")]
    BossUp,
}

trait Constants {
    const TOTAL_SUPPLY: u16 = 1000;
    const MIN: u64 = 2500000;
}

struct ConstantsImpl;

impl Constants for ConstantsImpl {}

impl Ledger {
    pub fn purchase_primary<'a>(
        purchaser: &AccountInfo<'a>,
        boss: &mut AccountInfo<'a>,
        boss_pubkey: &Pubkey,
        ledger: &mut Ledger,
    ) -> ProgramResult {
        match Ledger::validate_primary(ledger, boss, boss_pubkey) {
            Ok(_) => {
                match Ledger::collect(purchaser, boss) {
                    ok @ Ok(_) => {
                        ledger.purchased.push(purchaser.key());
                        ledger.original_supply_remaining = ledger.original_supply_remaining - 1;
                        ok
                    }
                    err @ Err(_) => { err }
                }
            }
            err @ Err(_) => { err }
        }
    }

    pub fn validate_primary(ledger: &Ledger, boss: &mut AccountInfo, boss_pubkey: &Pubkey) -> ProgramResult {
        match boss.key == boss_pubkey {
            true => {
                match ledger.original_supply_remaining > 0 {
                    true => { Ok(()) }
                    false => { Err(LedgerErrors::SoldOut.into()) }
                }
            }
            false => Err(LedgerErrors::BossUp.into())
        }
    }

    pub fn collect<'a>(purchaser: &AccountInfo<'a>, boss: &AccountInfo<'a>) -> ProgramResult {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &purchaser.key(),
            &boss.key(),
            ConstantsImpl::MIN,
        );
        let purchaser_copy = purchaser.clone();
        let boss_copy = boss.clone();
        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                purchaser_copy,
                boss_copy
            ],
        )
    }
}
