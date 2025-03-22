// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/VaultLibrary.sol";

contract Vault {
    LayoutLibrary.VaultLayout internal vaultVars;

    address public owner;
    address public subscriptionContract;
    address public platformTreasuryAddress;
    uint256 public platformEarnings;

    // Events
    event PlatformPercentageUpdated(uint256 newPercentage);
    event CreatorPayoutProcessed(
        address indexed creator,
        uint256 amount,
        uint256 timestamp
    );
    event SubscriptionContractUpdated(address newSubscriptionContract);
    event PlatformFeesWithdrawn(address indexed recipient, uint256 amount);
    event PlatformTreasuryAddressUpdated(address indexed newTreasury);
    event PlatformEarningsAdded(uint256 amount, uint256 newTotal);

    constructor(address _tokenAddress) {
        vaultVars.token = IERC20(_tokenAddress);
        vaultVars.platformPercentage = 5; // Default platform fee set to 5%
        owner = msg.sender;
        platformEarnings = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlySubscription() {
        require(
            msg.sender == subscriptionContract,
            "Only Subscription contract can call this function"
        );
        _;
    }

    modifier onlyPlatformTreasury() {
        require(
            msg.sender == platformTreasuryAddress,
            "Only platform treasury"
        );
        _;
    }

    // Set the Subscription contract address
    function setSubscriptionContract(
        address _subscriptionContract
    ) external onlyOwner {
        subscriptionContract = _subscriptionContract;
        emit SubscriptionContractUpdated(_subscriptionContract);
    }

    // Set the platform treasury address
    function setPlatformTreasuryAddress(address _treasury) external onlyOwner {
        platformTreasuryAddress = _treasury;
        emit PlatformTreasuryAddressUpdated(_treasury);
    }

    // Function to handle creator payouts
    function CreatorPayout(
        uint256 _amount,
        address _creator
    ) external onlySubscription {
        require(_amount > 0, "Amount must be greater than zero");

        // Simply transfer the amount to the creator
        require(
            vaultVars.token.transfer(_creator, _amount),
            "Payout transfer failed"
        );

        // Emit event
        emit CreatorPayoutProcessed(_creator, _amount, block.timestamp);
    }

    // Function to update platform percentage fee
    function setPlatformPercentage(uint256 _percentage) external onlyOwner {
        require(_percentage <= 100, "Percentage cannot exceed 100");
        vaultVars.platformPercentage = _percentage;
        emit PlatformPercentageUpdated(_percentage);
    }

    // Withdraw platform fees to the treasury
    function withdrawPlatformFees(
        uint256 _amount
    ) external onlyPlatformTreasury {
        require(_amount <= platformEarnings, "Insufficient platform earnings");
        platformEarnings -= _amount;

        // Transfer the tokens to the caller (PlatformTreasury contract)
        bool success = vaultVars.token.transfer(msg.sender, _amount);
        require(success, "Token transfer failed");

        emit PlatformFeesWithdrawn(msg.sender, _amount);
    }

    // Get the current platform percentage
    function getPlatformPercentage() external view returns (uint256) {
        return vaultVars.platformPercentage;
    }

    // Get the token address
    function getTokenAddress() external view returns (address) {
        return address(vaultVars.token);
    }
}
