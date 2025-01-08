// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/AppLibrary.sol";

interface ITippingSystem {
    // Set the token amount for a specific tip
    function setTipAmount(uint256 _amount) external;

    // Tip a creator using platform tokens
    function tipCreator(address _creator, uint256 _amount) external;

    // Fetch all tippers for a specific creator
    function fetchTippers(address _creator) external view returns (AppLibrary.User[] memory);

    // Fetch total tips received by a specific creator
    function fetchTotalTips(address _creator) external view returns (uint256);

    // Fetch tipping leaderboard
    function fetchLeaderboard() external view returns (AppLibrary.User[] memory);

    // Assign badges based on tipping activity
    function assignBadges(address _user) external;

    // Fetch badges for a user
    function fetchBadges(address _user) external view returns (string[] memory);
}
