// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subscription {
    IERC20 public token;
    mapping(address => bool) public isSubscribed;
    mapping(address => uint256) public subscriptionExpiry;
    mapping(address => uint256) public subscriptionType;

    event Subscribed(address indexed user, uint256 expiry, uint256 subsciptionPackage);
    event SubscriptionExtended(address indexed user, uint256 expiry);

    uint256 subscriptionBaseFee = 1e2;
    uint256 discountRate3 = 7;
    uint256 discountRate6 = 15;
    uint256 discountRate12 = 25;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    // Modifier to check if user is subscribed
    modifier onlySubscribed() {
        require(isSubscribed[msg.sender], "User is not subscribed");
        _;
    }

    // Subscribe to platform using tokens
    function subscribeOneMonth() public {
        require(!isSubscribed[msg.sender] && !(subscriptionExpiry[msg.sender] >= block.timestamp), "User is already subscribed");

        uint256 subDays = 30 * 1 days;
        uint256 baseAmount = subDays * subscriptionBaseFee;

        uint256 amount = baseAmount;

        subscriptionType[msg.sender] = 1;
        // Update subscription details
        isSubscribed[msg.sender] = true;

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        subscriptionExpiry[msg.sender] = block.timestamp + subDays;

        emit Subscribed(msg.sender, subscriptionExpiry[msg.sender], 1);
    }

    function subscribeThreeMonths() public {
        require(!isSubscribed[msg.sender] && !(subscriptionExpiry[msg.sender] >= block.timestamp), "User is already subscribed");

        uint256 subDays = 90 * 1 days;
        uint256 baseAmount = subDays * subscriptionBaseFee;

        uint256 discount = baseAmount * discountRate3 / 100;

        uint256 amount = baseAmount - discount;

        // Update subscription details
        isSubscribed[msg.sender] = true;
        subscriptionType[msg.sender] = 2;

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        subscriptionExpiry[msg.sender] = block.timestamp + subDays;

        emit Subscribed(msg.sender, subscriptionExpiry[msg.sender], 2);
    }

    function subscribeSixMonths() public {
        require(!isSubscribed[msg.sender] && !(subscriptionExpiry[msg.sender] >= block.timestamp), "User is already subscribed");

        uint256 subDays = 180 * 1 days;
        uint256 baseAmount = subDays * subscriptionBaseFee;

        uint256 discount = baseAmount * discountRate6 / 100;

        uint256 amount = baseAmount - discount;

        // Update subscription details
        isSubscribed[msg.sender] = true;
        subscriptionType[msg.sender] = 3;

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        subscriptionExpiry[msg.sender] = block.timestamp + subDays;

        emit Subscribed(msg.sender, subscriptionExpiry[msg.sender], 3);
    }


     function subscribe12Months() public {
        require(!isSubscribed[msg.sender] && !(subscriptionExpiry[msg.sender] >= block.timestamp), "User is already subscribed");

        uint256 subDays = 365  * 1 days;
        uint256 baseAmount = subDays * subscriptionBaseFee;

        uint256 discount = baseAmount * discountRate12 / 100;

        uint256 amount = baseAmount - discount;

        // Update subscription details
        isSubscribed[msg.sender] = true;

        subscriptionType[msg.sender] = 3;

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        subscriptionExpiry[msg.sender] = block.timestamp + subDays;

        emit Subscribed(msg.sender, subscriptionExpiry[msg.sender], 3);
    }

    // Check if user is subscribed
    function isUserSubscribed(address _user) public view returns (bool) {
        if (isSubscribed[_user] && subscriptionExpiry[_user] >= block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    function getSubscriptionPackage(address _user) public view returns (uint256) {
        if (isSubscribed[_user] && subscriptionExpiry[_user] >= block.timestamp) {
            return subscriptionType[msg.sender];
        } else {
            return 0;
        }
    }
}
