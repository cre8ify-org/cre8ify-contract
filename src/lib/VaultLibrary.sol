// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LayoutLibrary.sol";

library VaultLibrary {
    event Tipped(
        address indexed creator,
        address indexed tipper,
        uint256 amount
    );
    event WithdrawnAccrued(address indexed creator, uint256 amount);

    /**
     * @notice Function to tip a creator
     * @param amount The amount of tokens to tip
     * @param tipper The address of the tipper
     * @param creator The address of the creator being tipped
     * @param vaultVars The VaultLayout storage containing tipping information
     */
    function tipCreator(
        uint256 amount,
        address tipper,
        address creator,
        LayoutLibrary.VaultLayout storage vaultVars
    ) external {
        require(
            vaultVars.token.balanceOf(tipper) >= amount,
            "Insufficient balance"
        );
        require(amount > 0, "Tip amount must be greater than zero");

        // Transfer tokens from tipper to the contract
        require(
            vaultVars.token.transferFrom(tipper, address(this), amount),
            "Token transfer failed"
        );

        // Update the creator's accrued amount and overall tipping balance
        vaultVars.creatorAccrued[creator] += amount;
        vaultVars.tippingBalances += amount;

        emit Tipped(creator, tipper, amount);
    }

    /**
     * @notice Function for a creator to withdraw their accrued tips
     * @param amount The amount of tokens to withdraw
     * @param creator The address of the creator withdrawing tips
     * @param vaultVars The VaultLayout storage containing tipping information
     */
    function creatorPayout(
        uint256 amount,
        address creator,
        LayoutLibrary.VaultLayout storage vaultVars
    ) external {
        require(
            vaultVars.creatorAccrued[creator] >= amount,
            "Insufficient funds"
        );
        require(amount > 0, "Payout amount must be greater than zero");

        // Update balances
        vaultVars.creatorAccrued[creator] -= amount;
        vaultVars.tippingBalances -= amount;

        // Transfer tokens to the creator
        require(vaultVars.token.transfer(creator, amount), "Payout failed");

        emit WithdrawnAccrued(creator, amount);
    }

    /**
     * @notice View function to check a creator's accrued balance
     * @param creator The address of the creator
     * @param vaultVars The VaultLayout storage containing tipping information
     * @return uint256 The accrued balance of the creator
     */
    function getCreatorAccrued(
        address creator,
        LayoutLibrary.VaultLayout storage vaultVars
    ) external view returns (uint256) {
        return vaultVars.creatorAccrued[creator];
    }

    /**
     * @notice View function to check the total tipping balances in the contract
     * @param vaultVars The VaultLayout storage containing tipping information
     * @return uint256 The total tipping balance held in the contract
     */
    function getTotalTippingBalances(
        LayoutLibrary.VaultLayout storage vaultVars
    ) external view returns (uint256) {
        return vaultVars.tippingBalances;
    }
}
