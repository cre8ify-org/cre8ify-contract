// Subscription.sol
pragma solidity ^0.8.26;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";

contract Subscription {
    LayoutLibrary.SubscriptionLayout internal subscriptionVars;

    uint256 public platformPercentage;
    mapping(address => uint256) public creatorAccruedTips;

    // Events
    event TipProcessed(
        address indexed creator,
        uint256 amount,
        uint256 platformFee
    );
    event PayoutProcessed(
        address indexed creator,
        uint256 amount,
        uint256 timestamp
    );

    constructor(
        address _tokenAddress,
        address _vaultAddress,
        address _authorization
    ) {
        subscriptionVars.token = IERC20(_tokenAddress);
        subscriptionVars.vault = IVault(_vaultAddress);
        subscriptionVars.authorizationContract = IAuthorization(_authorization);
        platformPercentage = 5; // Default platform fee set to 5%
    }

    modifier onlyOwner() {
        require(
            msg.sender == subscriptionVars.authorizationContract.owner(),
            "Only owner can call this function"
        );
        _;
    }

    // Function to update the platform's percentage fee
    function setPlatformPercentage(uint256 _percentage) public onlyOwner {
        require(_percentage <= 100, "Percentage cannot exceed 100");
        platformPercentage = _percentage;
    }

    // Tip Creator logic
    function tipCreator(address _creator, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");

        // Calculate the creator's amount after platform fee
        uint256 platformFee = (_amount * platformPercentage) / 100;
        uint256 creatorAmount = _amount - platformFee;

        // Update accrued tips with the amount AFTER the platform fee
        creatorAccruedTips[_creator] += creatorAmount;

        // Transfer tokens from user to vault
        require(
            subscriptionVars.token.transferFrom(
                msg.sender,
                address(subscriptionVars.vault),
                _amount
            ),
            "Transfer failed"
        );

        // Emit event
        emit TipProcessed(_creator, _amount, platformFee);
    }

    // Function for creators to claim their tips
    function claimTips() public {
        uint256 accruedAmount = creatorAccruedTips[msg.sender];
        require(accruedAmount > 0, "No tips to claim");

        // Reset the creator's accrued tips balance
        creatorAccruedTips[msg.sender] = 0;

        // Request the Vault to transfer tokens to the creator
        subscriptionVars.vault.CreatorPayout(accruedAmount, msg.sender);

        // Emit event
        emit PayoutProcessed(msg.sender, accruedAmount, block.timestamp);
    }

    // Function to check a creator's accrued tips
    function getAccruedTips(address _creator) public view returns (uint256) {
        return creatorAccruedTips[_creator];
    }
}
