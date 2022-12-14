use anchor_lang::prelude::*;

declare_id!("24PR27toKrLys6EqJmkMp1U2AAykL6vffMFFcZMhXSqL");

#[program]
pub mod somos_datum {
    use super::*;

    pub fn initialize_increment(
        _ctx: Context<InitializeIncrement>,
    ) -> Result<()> {
        Ok(())
    }

    pub fn publish_assets(
        ctx: Context<PublishAssets>,
        seed: u8,
        url: [u8; 78],
    ) -> Result<()> {
        let datum = &mut ctx.accounts.datum;
        let increment_pda = &mut ctx.accounts.increment;
        let tariff = &ctx.accounts.tariff;
        let tariff_authority = &ctx.accounts.tariff_authority;
        let payer = &ctx.accounts.payer;
        // increment
        let increment = increment_pda.increment + 1;
        // assert that datum is produced in sequence
        assert_eq!(increment, seed);
        increment_pda.increment = increment;
        // mint
        datum.mint = ctx.accounts.mint.key();
        // url
        datum.url = url;
        // authority
        datum.authority = payer.key();
        // datum pda
        datum.seed = seed;
        // tariff
        Tariff::pay_tariff(tariff, tariff_authority, payer)
    }

    pub fn initialize_tariff(
        ctx: Context<InitializeTariff>,
    ) -> Result<()> {
        let tariff = &mut ctx.accounts.tariff;
        let payer = &mut ctx.accounts.payer;
        // init
        tariff.authority = payer.key();
        tariff.tariff = 0;
        Ok(())
    }

    pub fn transfer_tariff_authority(
        ctx: Context<TransferTariffAuthority>,
    ) -> Result<()> {
        let tariff = &mut ctx.accounts.tariff;
        let to = &ctx.accounts.to;
        // transfer authority
        tariff.authority = to.key();
        Ok(())
    }

    pub fn set_new_tariff(
        ctx: Context<SetNewTariff>,
        new_tariff: u64,
    ) -> Result<()> {
        let tariff = &mut ctx.accounts.tariff;
        // set new tariff
        tariff.tariff = new_tariff;
        Ok(())
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// DATUM ///////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#[derive(Accounts)]
pub struct InitializeIncrement<'info> {
    #[account(init,
    seeds = [mint.key().as_ref(), payer.key().as_ref()], bump,
    payer = payer,
    space = Increment::SPACE
    )]
    pub increment: Account<'info, Increment>,
    #[account()]
    /// CHECK: excluding check for spl-mint type
    /// provides run-time benefits in avoiding additional
    /// deserialization & binary dependencies
    pub mint: UncheckedAccount<'info>,
    #[account(mut)]
    pub payer: Signer<'info>,
    // system program
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(seed: u8)]
pub struct PublishAssets<'info> {
    #[account(init,
    seeds = [mint.key().as_ref(), payer.key().as_ref(), & [seed]], bump,
    payer = payer,
    space = Datum::SPACE
    )]
    pub datum: Account<'info, Datum>,
    #[account(mut, seeds = [mint.key().as_ref(), payer.key().as_ref()], bump)]
    pub increment: Account<'info, Increment>,
    #[account()]
    /// CHECK: excluding check for spl-mint type
    /// provides run-time benefits in avoiding additional
    /// deserialization & binary dependencies
    pub mint: UncheckedAccount<'info>,
    #[account(mut)]
    pub payer: Signer<'info>,
    #[account(seeds = [b"tarifftariff"], bump,
    constraint = tariff.authority == tariff_authority.key()
    )]
    pub tariff: Account<'info, Tariff>,
    #[account(mut)]
    pub tariff_authority: SystemAccount<'info>,
    // system program
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct InitializeTariff<'info> {
    #[account(init,
    seeds = [b"tarifftariff"], bump,
    payer = payer,
    space = Tariff::SPACE
    )]
    pub tariff: Account<'info, Tariff>,
    #[account(mut)]
    pub payer: Signer<'info>,
    // system program
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct TransferTariffAuthority<'info> {
    #[account(mut,
    seeds = [b"tarifftariff"], bump,
    constraint = tariff.authority == from.key()
    )]
    pub tariff: Account<'info, Tariff>,
    #[account()]
    pub from: Signer<'info>,
    #[account()]
    pub to: SystemAccount<'info>,
}

#[derive(Accounts)]
pub struct SetNewTariff<'info> {
    #[account(mut,
    seeds = [b"tarifftariff"], bump,
    constraint = tariff.authority == tariff_authority.key()
    )]
    pub tariff: Account<'info, Tariff>,
    #[account()]
    pub tariff_authority: Signer<'info>,
}

#[account]
pub struct Datum {
    // target mint
    pub mint: Pubkey,
    // upload url
    pub url: [u8; 78],
    // authority
    pub authority: Pubkey,
    // pda
    pub seed: u8,
}

impl Datum {
    const SPACE: usize = 8 + 32 + 78 + 32 + 1 + 1;
}

#[account]
pub struct Increment {
    pub increment: u8,
}

impl Increment {
    const SPACE: usize = 8 + 1;
}

#[account]
pub struct Tariff {
    pub authority: Pubkey,
    pub tariff: u64,
}

impl Tariff {
    const SPACE: usize = 8 + 32 + 8;

    pub fn pay_tariff<'a>(
        tariff: &Tariff, tariff_authority: &SystemAccount<'a>, payer: &Signer<'a>,
    ) -> Result<()> {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &payer.key(),
            &tariff_authority.key(),
            tariff.tariff,
        );
        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                payer.to_account_info(),
                tariff_authority.to_account_info()
            ],
        ).map_err(Into::into)
    }
}

#[error_code]
pub enum CustomErrors {
    #[msg("decentralized assets should be immutable.")]
    ImmutableAssets,
}
