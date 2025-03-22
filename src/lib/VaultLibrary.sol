// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./LayoutLibrary.sol";

library VaultLibrary {
    event Tipped(
        address indexed creator,
        address indexed tipper,
        uint256 amount,
        uint256 platformFee
    );
    event Subscribed(
        address indexed creator,
        address indexed subscriber,
        uint256 amount,
        uint256 platformFee
    );
    event WithdrawnAccured(address indexed creator, uint256 amount);
    event PlatformFeeDeducted(uint256 amount);

    // Tip a creator (with platform fee deduction)
    function tipCreator(
        uint256 amount,
        address _tipper,
        address _creator,
        LayoutLibrary.VaultLayout storage vaultVars
    ) external {
        require(
            vaultVars.token.balanceOf(_tipper) >= amount,
            "Insufficient balance"
        );

        // Deduct platform fee
        uint256 platformFee = (amount * vaultVars.platformPercentage) / 100;
        uint256 remainingAmount = amount - platformFee;

        // Transfer platform fee to the platform
        vaultVars.token.transferFrom(_tipper, address(this), platformFee);
        vaultVars.platformEarnings += platformFee;

        // Transfer remaining amount to the creator
        vaultVars.token.transferFrom(_tipper, _creator, remainingAmount);
        vaultVars.creatorAccured[_creator] += remainingAmount;

        emit Tipped(_creator, _tipper, remainingAmount, platformFee);
        emit PlatformFeeDeducted(platformFee);
    }

    // Subscribe to a creator (with platform fee deduction)
    function subscribe(
        uint256 amount,
        address _subscriber,
        address _creator,
        LayoutLibrary.VaultLayout storage vaultVars
    ) external {
        require(
            vaultVars.token.balanceOf(_subscriber) >= amount,
            "Insufficient balance"
        );

        // Deduct platform fee
        uint256 platformFee = (amount * vaultVars.platformPercentage) / 100;
        uint256 remainingAmount = amount - platformFee;

        // Transfer platform fee to the platform
        vaultVars.token.transferFrom(_subscriber, address(this), platformFee);
        vaultVars.platformEarnings += platformFee;

        // Transfer remaining amount to the creator
        vaultVars.token.transferFrom(_subscriber, _creator, remainingAmount);
        vaultVars.creatorAccured[_creator] += remainingAmount;

        emit Subscribed(_creator, _subscriber, remainingAmount, platformFee);
        emit PlatformFeeDeducted(platformFee);
    }

    // Creator payout (with platform fee deduction)
    function CreatorPayout(
        uint256 amount,
        address _creator,
        LayoutLibrary.VaultLayout storage vaultVars
    ) external {
        require(
            vaultVars.creatorAccured[_creator] >= amount,
            "Insufficient balance"
        );

        // Deduct platform fee
        uint256 platformFee = (amount * vaultVars.platformPercentage) / 100;
        uint256 remainingAmount = amount - platformFee;

        // Transfer platform fee to the platform
        vaultVars.token.transfer(address(this), platformFee);
        vaultVars.platformEarnings += platformFee;

        // Transfer remaining amount to the creator
        vaultVars.token.transfer(_creator, remainingAmount);
        vaultVars.creatorAccured[_creator] -= amount;

        emit WithdrawnAccured(_creator, remainingAmount);
        emit PlatformFeeDeducted(platformFee);
    }
}
