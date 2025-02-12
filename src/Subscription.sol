// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/SubscriptionLibrary.sol";

contract Subscription {
    LayoutLibrary.SubscriptionLayout internal subscriptionVars;

    uint256 public platformPercentage;
    uint256 public platformEarnings;
    mapping(address => uint256) public creatorTippingCount;

    event PlatformPercentageUpdated(uint256 newPercentage);
    event TipProcessed(
        address indexed creator,
        uint256 amount,
        uint256 platformFee
    );

    constructor(
        address _tokenAddress,
        address _vaultAddress,
        address _authorization
    ) {
        subscriptionVars.token = IERC20(_tokenAddress);
        subscriptionVars.vault = IVault(_vaultAddress);
        owner = msg.sender;
        subscriptionVars.authorizationContract = IAuthorization(_authorization);
        platformPercentage = 5; // Default platform fee set to 5%
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Function to update the platform's percentage fee
    function setPlatformPercentage(uint256 _percentage) public onlyOwner {
        require(_percentage <= 100, "Percentage cannot exceed 100");
        platformPercentage = _percentage;
        emit PlatformPercentageUpdated(_percentage);
    }

    // Helper function to calculate and deduct the platform fee
    function _processTip(
        address _creator,
        uint256 _amount
    ) internal returns (uint256) {
        uint256 platformFee = (_amount * platformPercentage) / 100;
        uint256 remainingAmount = _amount - platformFee;

        platformEarnings += platformFee; // Add platform fee to earnings

        // Transfer platform fee to the platform vault
        require(
            subscriptionVars.token.transferFrom(
                msg.sender,
                address(subscriptionVars.vault),
                platformFee
            ),
            "Platform fee transfer failed"
        );

        // Transfer remaining tip to the creator
        require(
            subscriptionVars.token.transferFrom(
                msg.sender,
                _creator,
                remainingAmount
            ),
            "Tip transfer failed"
        );

        emit TipProcessed(_creator, remainingAmount, platformFee);
        return remainingAmount;
    }

    // Updated tipping function with platform fee deduction
    function tipCreator(address _creator, uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        _processTip(_creator, amount);

        // Increment tipping count for the creator
        creatorTippingCount[_creator]++;
    }

    // Function to retrieve the total tipping count for a creator
    function getCreatorTippingCount(
        address _creator
    ) public view returns (uint256) {
        return creatorTippingCount[_creator];
    }

    function setMonthlySubscriptionAmount(uint256 _amount) public {
        SubscriptionLibrary.setMonthlySubscriptionAmount(
            _amount,
            subscriptionVars
        );
    }

    // function tipCreator(address _creator, uint256 amount) public {
    //     SubscriptionLibrary.tipCreator(_creator, amount, subscriptionVars);
    // }

    function fetchSubscribers(
        address _creator
    ) public view returns (AppLibrary.User[] memory) {
        return SubscriptionLibrary.fetchSubscribers(_creator, subscriptionVars);
    }

    function fetchSubscribedTo(
        address _subscriber
    ) public view returns (AppLibrary.User[] memory) {
        return
            SubscriptionLibrary.fetchSubscribedTo(
                _subscriber,
                subscriptionVars
            );
    }

    function getCreatorSubscriptionAmount(
        address _creator
    ) public view returns (uint256) {
        return
            SubscriptionLibrary.getCreatorSubscriptionAmount(
                _creator,
                subscriptionVars
            );
    }

    // Subscribe to platform using tokens
    function subscribeToCreator(address _creator, uint256 _amount) public {
        SubscriptionLibrary.subscribeToCreator(
            _creator,
            _amount,
            subscriptionVars
        );
    }

    // Check if user is subscribed to creator
    function checkSubscribtionToCreatorStatus(
        address _creator,
        address _subscriber
    ) public view returns (bool) {
        return
            SubscriptionLibrary.checkSubscribtionToCreatorStatus(
                _creator,
                _subscriber,
                subscriptionVars
            );
    }

    // Payout money earned
    function payout(uint256 _amount, address _creator) public {
        SubscriptionLibrary.payout(_amount, _creator, subscriptionVars);
    }
}
