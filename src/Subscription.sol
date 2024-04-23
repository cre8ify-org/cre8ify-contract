// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Authorization.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Subscription is Authorization {
    IERC20 public token;
    mapping(address => bool) public isSubscribed;
    mapping(address => uint256) public subscriptionExpiry;

    event Subscribed(address indexed user, uint256 expiry);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    // Modifier to check if user is subscribed
    modifier onlySubscribed() {
        require(isSubscribed[msg.sender], "User is not subscribed");
        _;
    }

    // Subscribe to platform using tokens
    function subscribe(uint256 _duration) public {
        require(!isSubscribed[msg.sender], "User is already subscribed");

        uint256 amount = _duration * 1 ether; // Assuming 1 token = 1 ether

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        // Update subscription details
        isSubscribed[msg.sender] = true;
        subscriptionExpiry[msg.sender] = block.timestamp + _duration;

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
    function extendSubscription(uint256 _duration) public onlySubscribed {
        uint256 amount = _duration * 1 ether; // Assuming 1 token = 1 ether

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        // Extend subscription expiry
        subscriptionExpiry[msg.sender] += _duration;

        emit Subscribed(msg.sender, subscriptionExpiry[msg.sender]);
    }

    // Renew subscription
    function renewSubscription(uint256 _duration) public onlySubscribed {
        uint256 amount = _duration * 1 ether; // Assuming 1 token = 1 ether

        // Transfer tokens from user to contract
        token.transferFrom(msg.sender, address(this), amount);

        // Renew subscription expiry
        subscriptionExpiry[msg.sender] = block.timestamp + _duration;

        emit Subscribed(msg.sender, subscriptionExpiry[msg.sender]);
    }
}
