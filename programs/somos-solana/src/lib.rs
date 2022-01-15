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
    #[account(mut, seeds = [b"miller".as_ref()], bump = partition_two.bump)]
    pub partition_two: Account<'info, Partition>,
}

#[account]
pub struct Partition {
    pub data: String,
    pub bump: u8,
}
