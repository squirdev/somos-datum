use anchor_lang::prelude::*;

declare_id!("AgxH9tmJsyVHiN7c6mMwkPh77dzgQxWQv1o1GgeSHFtN");

#[program]
pub mod somos_solana {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, bump: u8, title: String, one: Song, two: Song) -> ProgramResult {
        let music_account = &mut ctx.accounts.music_account;
        music_account.title = title;
        music_account.one = one;
        music_account.two = two;
        music_account.bump = bump;
        Ok(())
    }

    pub fn update(ctx: Context<Update>, title: String) -> ProgramResult {
        let music_account = &mut ctx.accounts.music_account;
        music_account.title = title;
        Ok(())
    }
}

#[derive(Accounts)]
#[instruction(bump: u8)]
pub struct Initialize<'info> {
    #[account(init, seeds = [b"somos_seed".as_ref()], bump = bump, payer = user, space = 16 + 16)]
    music_account: Account<'info, Project>,
    #[account(mut)]
    user: Signer<'info>,
    system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Update<'info> {
    #[account(mut, seeds = [b"somos_seed".as_ref()], bump = music_account.bump)]
    music_account: Account<'info, Project>,
}

#[account]
pub struct Project {
    pub title: String,
    pub one: Song,
    pub two: Song,
    // used to persist data with unique seed + .bump
    pub bump: u8,
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone)]
pub struct Song {
    pub title: String,
    pub encoded_wav: String,
}
