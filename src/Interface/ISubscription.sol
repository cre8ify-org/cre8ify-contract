// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/AppLibrary.sol";

interface ISubscription {

    function setMonthlySubscriptionAmount(uint256 _amount) external ;

    function tipCreator(address _creator, uint256 amount) external ;

    function fetchSubscribers(address _creator) external view returns(AppLibrary.User[] memory) ;

    function fetchSubscribedTo(address _subscriber) external view returns(AppLibrary.User[] memory);

    // Subscribe to platform using tokens
    function subscribeToCreator(address _creator, uint256 _amount) external;

    // Check if user is subscribed to creator
    function checkSubscribtionToCreatorStatus(address _creator, address _subscriber) external view returns (bool);
}
