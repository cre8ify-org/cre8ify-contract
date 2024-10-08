// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/SubscriptionLibrary.sol";

contract Subscription {
    
    LayoutLibrary.SubscriptionLayout internal subscriptionVars;

    address owner;

    constructor(address _tokenAddress, address _vaultAddress, address _authorization) {
        
        subscriptionVars.token = IERC20(_tokenAddress);

        subscriptionVars.vault = IVault(_vaultAddress);

        owner = msg.sender;

        subscriptionVars.authorizationContract = IAuthorization(_authorization);
    }

    function setMonthlySubscriptionAmount(uint256 _amount) public {

        SubscriptionLibrary.setMonthlySubscriptionAmount(_amount, subscriptionVars);

    }

    function tipCreator(address _creator, uint256 amount) public {

        SubscriptionLibrary.tipCreator(_creator, amount, subscriptionVars);

    }

    function fetchSubscribers(address _creator) public view returns(AppLibrary.User[] memory) {

        return SubscriptionLibrary.fetchSubscribers(_creator, subscriptionVars);

    }

    function fetchSubscribedTo(address _subscriber) public view returns(AppLibrary.User[] memory) {

        return SubscriptionLibrary.fetchSubscribedTo(_subscriber, subscriptionVars);

    }

    function getCreatorSubscriptionAmount(address _creator) public view returns(uint256){

        return SubscriptionLibrary.getCreatorSubscriptionAmount(_creator, subscriptionVars);

    }

    // Subscribe to platform using tokens
    function subscribeToCreator(address _creator, uint256 _amount) public {
        
        SubscriptionLibrary.subscribeToCreator(_creator, _amount, subscriptionVars);

    }

    // Check if user is subscribed to creator
    function checkSubscribtionToCreatorStatus(address _creator, address _subscriber) public view returns (bool) {
        
        return SubscriptionLibrary.checkSubscribtionToCreatorStatus(_creator, _subscriber, subscriptionVars);

    }

    // Payout money earned
    function payout(uint256 _amount, address _creator) public {

        SubscriptionLibrary.payout(_amount, _creator, subscriptionVars);
        
    }
}
