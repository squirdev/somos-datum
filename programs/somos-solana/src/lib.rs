use anchor_lang::prelude::*;

declare_id!("ETsHd2t2ZE5NEPa1GnrAvjuy8mFayXETxf6kCQib479G");

#[program]
pub mod somos_solana {
    use super::*;

    pub fn initialize_ledger(
        ctx: Context<InitializeLedger>,
        seed: [u8; 16],
        n: u16,
        price: u64,
    ) -> Result<()> {
        let ledger = &mut ctx.accounts.ledger;
        // init ledger
        ledger.price = price;
        ledger.original_supply_remaining = n;
        ledger.owners = Vec::new();
        // persist boss for validation
        ledger.boss = ctx.accounts.user.key();
        // pda
        ledger.seed = seed;
        ledger.bump = *ctx.bumps.get("ledger").unwrap();
        Ok(())
    }

    // TODO; ledger dependency
    pub fn initialize_escrow(
        ctx: Context<InitializeEscrow>,
        seed: [u8; 16],
    ) -> Result<()> {
        let escrow = &mut ctx.accounts.escrow;
        let ledger = &mut ctx.accounts.ledger;
        // init escrow
        escrow.items = Vec::new();
        // grab boss from ledger
        escrow.boss = ledger.boss;
        // pda
        escrow.seed = seed;
        escrow.bump = *ctx.bumps.get("escrow").unwrap();
        Ok(())
    }

    pub fn purchase_primary(
        ctx: Context<PurchasePrimary>
    ) -> Result<()> {
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

    pub fn submit_to_escrow(
        ctx: Context<SubmitToEscrow>,
        price: u64,
    ) -> Result<()> {
        let seller = &mut ctx.accounts.seller;
        let escrow = &mut ctx.accounts.escrow;
        let ledger = &ctx.accounts.ledger;
        Escrow::submit_to_escrow(seller, price, escrow, ledger)
    }

    pub fn purchase_secondary(
        ctx: Context<PurchaseSecondary>,
        escrow_item: EscrowItem,
    ) -> Result<()> {
        let escrow = &mut ctx.accounts.escrow;
        let ledger = &mut ctx.accounts.ledger;
        let buyer = &mut ctx.accounts.buyer;
        let seller = &mut ctx.accounts.seller;
        let boss = &mut ctx.accounts.boss;
        Escrow::purchase_secondary(
            &escrow_item,
            escrow,
            ledger,
            buyer,
            seller,
            boss,
        )
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// PRIMARY MARKET //////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#[derive(Accounts)]
#[instruction(seed: [u8; 16])]
pub struct InitializeLedger<'info> {
    #[account(init, seeds = [& seed], bump, payer = user, space = 10240)]
    pub ledger: Account<'info, Ledger>,
    #[account(mut)]
    pub user: Signer<'info>,
    // system
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct PurchasePrimary<'info> {
    #[account(mut)]
    pub user: Signer<'info>,
    // used to validate against persisted boss
    #[account(mut)]
    pub boss: SystemAccount<'info>,
    #[account(mut, seeds = [& ledger.seed], bump = ledger.bump)]
    pub ledger: Account<'info, Ledger>,
    // system
    pub system_program: Program<'info, System>,
}

#[account]
pub struct Ledger {
    // supply
    pub price: u64,
    // TODO; specify resale on ledger init
    pub original_supply_remaining: u16,
    // owners
    pub owners: Vec<Pubkey>,
    // persist boss for validation
    pub boss: Pubkey,
    // pda
    pub seed: [u8; 16],
    pub bump: u8,
}

#[error_code]
pub enum LedgerErrors {
    #[msg("we've already sold-out. check the secondary market.")]
    SoldOut,
    #[msg("you can only pay the boss for this track.")]
    BossUp,
    #[msg("your public-key is not on the ledger.")]
    SellerNotOnLedger,
    #[msg("the item you've requested is not for sale.")]
    ItemNotForSale,
    #[msg("seller unauthorized to sell this item.")]
    UnauthorizedSeller,
}

impl Ledger {
    pub fn purchase_primary<'a>(
        purchaser: &mut Signer<'a>,
        boss: &mut SystemAccount<'a>,
        boss_pubkey: &Pubkey,
        ledger: &mut Ledger,
    ) -> Result<()> {
        match Ledger::validate_primary(ledger, boss, boss_pubkey) {
            Ok(_) => {
                match Ledger::collect(ledger.price, purchaser, boss) {
                    ok @ Ok(_) => {
                        ledger.owners.push(purchaser.key());
                        ledger.original_supply_remaining = ledger.original_supply_remaining - 1;
                        ok
                    }
                    err @ Err(_) => { err }
                }
            }
            err @ Err(_) => { err }
        }
    }

    pub fn validate_primary(ledger: &Ledger, boss: &mut SystemAccount, boss_pubkey: &Pubkey) -> Result<()> {
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

    pub fn collect<'a>(price: u64, purchaser: &Signer<'a>, boss: &SystemAccount<'a>) -> Result<()> {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &purchaser.key(),
            &boss.key(),
            price,
        );
        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                purchaser.to_account_info(),
                boss.to_account_info()
            ],
        ).map_err(Into::into)
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// SECONDARY MARKET ////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#[derive(Accounts)]
#[instruction(seed: [u8; 16])]
pub struct InitializeEscrow<'info> {
    #[account(init, seeds = [& seed], bump, payer = user, space = 10240)]
    pub escrow: Account<'info, Escrow>,
    #[account(seeds = [& ledger.seed], bump = ledger.bump)]
    pub ledger: Account<'info, Ledger>,
    #[account(mut)]
    pub user: Signer<'info>,
    // system
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct SubmitToEscrow<'info> {
    #[account(mut, seeds = [& escrow.seed], bump = escrow.bump)]
    pub escrow: Account<'info, Escrow>,
    #[account(mut, seeds = [& ledger.seed], bump = ledger.bump)]
    pub ledger: Account<'info, Ledger>,
    // pubkey on ledger
    pub seller: Signer<'info>,
    // system
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct PurchaseSecondary<'info> {
    #[account(mut, seeds = [& escrow.seed], bump = escrow.bump)]
    pub escrow: Account<'info, Escrow>,
    #[account(mut, seeds = [& ledger.seed], bump = ledger.bump)]
    pub ledger: Account<'info, Ledger>,
    // buyer
    #[account(mut)]
    pub buyer: Signer<'info>,
    // seller
    #[account(mut)]
    pub seller: SystemAccount<'info>,
    // used to validate against persisted boss
    #[account(mut)]
    pub boss: SystemAccount<'info>,
    // system
    pub system_program: Program<'info, System>,
}

#[account]
pub struct Escrow {
    pub items: Vec<EscrowItem>,
    // persist boss for validation
    pub boss: Pubkey,
    // pda
    pub seed: [u8; 16],
    pub bump: u8,
}

#[derive(AnchorSerialize, AnchorDeserialize, Clone)]
pub struct EscrowItem {
    pub price: u64,
    pub seller: Pubkey,
}

impl PartialEq for EscrowItem {
    fn eq(&self, other: &Self) -> bool {
        self.price == other.price && self.seller == other.seller
    }
}

impl Escrow {
    pub fn submit_to_escrow(
        seller: &mut Signer,
        price: u64,
        escrow: &mut Escrow,
        ledger: &Ledger,
    ) -> Result<()> {
        // validate seller
        match Escrow::validate_seller(seller, ledger) {
            Ok(_) => {
                // build item
                let escrow_item = EscrowItem { price, seller: *seller.key };
                // add item to escrow
                escrow.items.push(escrow_item);
                Ok(())
            }
            err @ Err(_) => { err }
        }
    }

    pub fn purchase_secondary<'a>(
        escrow_item: &EscrowItem,
        escrow: &mut Escrow,
        ledger: &mut Ledger,
        buyer: &mut Signer<'a>,
        seller: &mut SystemAccount<'a>,
        boss: &mut SystemAccount<'a>,
    ) -> Result<()> {
        // validate
        match Escrow::validate_escrow_item(escrow_item, escrow, seller) {
            Ok(_) => {
                // pop
                match Escrow::pop_escrow_item(escrow_item, escrow, ledger) {
                    Ok(_) => {
                        // push
                        ledger.owners.push(buyer.key());
                        // collect
                        Escrow::collect(escrow_item, buyer, seller, boss)
                    }
                    err @ Err(_) => { err }
                }
            }
            err @ Err(_) => { err }
        }
    }

    fn validate_seller(seller: &mut Signer, ledger: &Ledger) -> Result<()> {
        match ledger.owners.contains(seller.key) {
            true => { Ok(()) }
            false => { Err(LedgerErrors::SellerNotOnLedger.into()) }
        }
    }

    fn validate_escrow_item<'a>(
        escrow_item: &EscrowItem,
        escrow: &Escrow,
        seller: &SystemAccount<'a>,
    ) -> Result<()> {
        match escrow.items.contains(escrow_item) {
            true => {
                match &escrow_item.seller == seller.key {
                    true => { Ok(()) }
                    false => { Err(LedgerErrors::UnauthorizedSeller.into()) }
                }
            }
            false => { Err(LedgerErrors::ItemNotForSale.into()) }
        }
    }

    fn pop_escrow_item(
        escrow_item: &EscrowItem,
        escrow: &mut Escrow,
        ledger: &mut Ledger,
    ) -> Result<()> {
        // remove from escrow
        match Escrow::remove_from_vec(
            &mut escrow.items,
            escrow_item,
            LedgerErrors::ItemNotForSale,
        ) {
            Ok(_) => {
                // remove from ledger
                Escrow::remove_from_vec(
                    &mut ledger.owners,
                    &escrow_item.seller,
                    LedgerErrors::SellerNotOnLedger,
                )
            }
            err @ Err(_) => { err }
        }
    }

    fn remove_from_vec<T: std::cmp::PartialEq>(
        vec: &mut Vec<T>,
        item: &T,
        err: LedgerErrors,
    ) -> Result<()> {
        let maybe_ix = vec.iter().position(|x| x == item);
        match maybe_ix {
            None => { Err(err.into()) }
            Some(ix) => {
                vec.remove(ix);
                Ok(())
            }
        }
    }

    fn collect<'a>(
        escrow_item: &EscrowItem,
        buyer: &Signer<'a>,
        seller: &SystemAccount<'a>,
        boss: &SystemAccount<'a>,
    ) -> Result<()> {
        let seller_split: u64 = Escrow::split(0.95, escrow_item.price);
        let tx_seller = Escrow::_collect(seller_split, buyer, seller);
        match tx_seller {
            Ok(_) => {
                let boss_split: u64 = Escrow::split(0.05, escrow_item.price);
                let boss_tx = Escrow::_collect(boss_split, buyer, boss);
                boss_tx
            }
            err @ Err(_) => { err }
        }
    }

    fn _collect<'a>(price: u64, from: &Signer<'a>, to: &SystemAccount<'a>) -> Result<()> {
        let ix = anchor_lang::solana_program::system_instruction::transfer(
            &from.key(),
            &to.key(),
            price,
        );
        anchor_lang::solana_program::program::invoke(
            &ix,
            &[
                from.to_account_info(),
                to.to_account_info()
            ],
        ).map_err(Into::into)
    }

    fn split(percentage: f64, price: u64) -> u64 {
        let sol = anchor_lang::solana_program::native_token::lamports_to_sol(price);
        anchor_lang::solana_program::native_token::sol_to_lamports(sol * percentage)
    }
}