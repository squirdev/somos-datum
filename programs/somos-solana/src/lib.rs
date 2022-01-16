use anchor_lang::prelude::*;

declare_id!("AgxH9tmJsyVHiN7c6mMwkPh77dzgQxWQv1o1GgeSHFtN");

#[program]
pub mod somos_solana {
    use super::*;

    pub fn initialize_partition_one(
        ctx: Context<InitializeOne>,
        bump: u8,
    ) -> ProgramResult {
        let partition = &mut ctx.accounts.partition;
        partition.bump = bump;
        Ok(())
    }

    pub fn initialize_partition_two(
        ctx: Context<InitializeTwo>,
        bump: u8,
    ) -> ProgramResult {
        let partition = &mut ctx.accounts.partition;
        partition.bump = bump;
        partition.authority = ctx.accounts.user.key();
        Ok(())
    }

    pub fn initialize_ledger(
        ctx: Context<InitializeLedger>,
        bump: u8,
    ) -> ProgramResult {
        let ledger = &mut ctx.accounts.ledger;
        ledger.original_supply_remaining = ConstantsImpl::TOTAL_SUPPLY;
        ledger.purchased = Vec::new();
        ledger.secondary_market = Vec::new();
        ledger.bump = bump;
        Ok(())
    }

    pub fn update(
        ctx: Context<Update>,
        data_one: String,
        data_two: String,
    ) -> ProgramResult {
        let partition_one = &mut ctx.accounts.partition_one;
        let partition_two = &mut ctx.accounts.partition_two;
        partition_one.data = data_one;
        partition_two.data = data_two;
        Ok(())
    }
}

#[derive(Accounts)]
#[instruction(bump: u8)]
pub struct InitializeOne<'info> {
    #[account(init, seeds = [b"hemingway".as_ref()], bump = bump, payer = user, space = 10240)]
    pub partition: Account<'info, Partition>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(bump: u8)]
pub struct InitializeTwo<'info> {
    #[account(init, seeds = [b"miller".as_ref()], bump = bump, payer = user, space = 10240)]
    pub partition: Account<'info, Partition>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Update<'info> {
    #[account(mut, seeds = [b"hemingway".as_ref()], bump = partition_one.bump)]
    pub partition_one: Account<'info, Partition>,
    #[account(mut, seeds = [b"miller".as_ref()], bump = partition_two.bump, has_one = authority)]
    pub partition_two: Account<'info, Partition>,
    pub authority: Signer<'info>,
}

#[account]
pub struct Partition {
    pub data: String,
    pub bump: u8,
    // only init user can access
    pub authority: Pubkey,
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
    pub bump: u8,
}

#[error]
pub enum LedgerErrors {
    #[msg("we've already sold-out. check the secondary market.")]
    SoldOut,
    #[msg("nothing is for sale. try reaching out to an owner directly.")]
    NothingForSale,
}

trait Constants {
    const TOTAL_SUPPLY: u16 = 1000;
    const MIN: u64 = 500;
}

struct ConstantsImpl;

impl Constants for ConstantsImpl {}

impl Ledger {
    pub fn purchase_primary<'a>(purchaser: &AccountInfo<'a>, boss: AccountInfo<'a>, ledger: &mut Ledger) -> ProgramResult {
        match Ledger::validate_primary(ledger) {
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

    pub fn validate_primary(ledger: &Ledger) -> ProgramResult {
        if ledger.original_supply_remaining > 0 {
            Ok(())
        } else {
            Err(LedgerErrors::SoldOut.into())
        }
    }

    pub fn collect<'a>(purchaser: &AccountInfo<'a>, boss: AccountInfo<'a>) -> ProgramResult {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &purchaser.key(),
            &boss.key(),
            ConstantsImpl::MIN,
        );
        let purchaser_copy = purchaser.clone();
        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                purchaser_copy,
                boss
            ],
        )
    }
}