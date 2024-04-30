// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subscription {
    IERC20 public token;
    mapping(address => bool) public isSubscribed;
    mapping(address => uint256) public subscriptionExpiry;

    event Subscribed(address indexed user, uint256 expiry);
    event SubscriptionExtended(address indexed user, uint256 expiry);

    uint256 subscriptionBaseFee = 1e2;
    uint256 discountRate = 25;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    // Modifier to check if user is subscribed
    modifier onlySubscribed() {
        require(isSubscribed[msg.sender], "User is not subscribed");
        _;
    }

    // Subscribe to platform using tokens
    function subscribe(uint256 _days) public {
        require(!isSubscribed[msg.sender] && !(subscriptionExpiry[msg.sender] >= block.timestamp), "User is already subscribed");

        uint256 subDays = _days * 1 days;
        uint256 baseAmount = subDays * subscriptionBaseFee;

        uint256 discount = 0;
        if (_days >= 365 days) {
            discount = baseAmount * discountRate / 100;
        }

        uint256 amount = baseAmount - discount;

        // Update subscription details
        isSubscribed[msg.sender] = true;

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        subscriptionExpiry[msg.sender] = block.timestamp + subDays;

        emit Subscribed(msg.sender, subscriptionExpiry[msg.sender]);
    }

    // Check if user is subscribed
    function isUserSubscribed(address _user) public view returns (bool) {
        if (isSubscribed[_user] && subscriptionExpiry[_user] >= block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    // Extend subscription duration
    function extendSubscription(uint256 _days) public onlySubscribed {
        require(isSubscribed[msg.sender] && subscriptionExpiry[msg.sender] >= block.timestamp, "User is not subscribed");

        uint256 subDays = _days * 1 days;
        uint256 baseAmount = subDays * subscriptionBaseFee;

        uint256 discount = 0;
        if (_days >= 365 days) {
            discount = baseAmount * discountRate / 100;
        }

        uint256 amount = baseAmount - discount;

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        // Extend subscription expiry
        subscriptionExpiry[msg.sender] += subDays;

        emit SubscriptionExtended(msg.sender, subscriptionExpiry[msg.sender]);
    }
}
