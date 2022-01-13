use anchor_lang::prelude::*;

declare_id!("7PPNqpdvgetTjxaMnMR9ADqm2gSw8KwEpmKkRrq3ACNs");

#[program]
pub mod somos_solana {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, bump: u8, binary: u128) -> ProgramResult {
        let music_account = &mut ctx.accounts.music_account;
        music_account.binary = binary;
        music_account.bump = bump;
        Ok(())
    }

    pub fn update(ctx: Context<Update>, binary: u128) -> ProgramResult {
        let music_account = &mut ctx.accounts.music_account;
        music_account.binary = binary;
        Ok(())
    }
}

#[derive(Accounts)]
#[instruction(bump: u8)]
pub struct Initialize<'info> {
    #[account(init, seeds = [b"somos_seed".as_ref()], bump = bump, payer = user)]
    music_account: Account<'info, Music>,
    #[account(mut)]
    user: Signer<'info>,
    system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Update<'info> {
    #[account(mut, seeds = [b"somos_seed".as_ref()], bump = music_account.bump)]
    music_account: Account<'info, Music>,
}

#[account]
#[derive(Default)]
pub struct Music {
    binary: u128,
    bump: u8,
}
