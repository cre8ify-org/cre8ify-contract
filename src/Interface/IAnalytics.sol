// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/AppLibrary.sol";

interface IAnalytics {
    // Track Free content likes
    function trackFreeLike(uint256 _id) external;

    // Track Free content dislikes
    function trackFreeDislike(uint256 _id) external;

    // Track Free content ratings
    function trackFreeRating(uint256 _id, uint256 _rating) external;

    // Track Exclusive content likes
    function trackExclusiveLike(uint256 _id) external;

    // Track Exclusive content dislikes
    function trackExclusiveDislike(uint256 _id) external;

    // Track Exclusive content ratings
    function trackExclusiveRating(uint256 _id, uint256 _rating) external;

    // Track Creator rating
    function trackCreatorRating(address _creator, uint256 _rating) external;

    // Track analytics
    function trackFollower(address _creator, bool inc) external;

    // Get Free content analytics
    function getFreeContentAnalytics(
        uint256 _id
    ) external view returns (AppLibrary.ContentAnalytics memory);

    // Get exclusive content analytics
    function getExclusiveContentAnalytics(
        uint256 _id
    ) external view returns (AppLibrary.ContentAnalytics memory);

    // Get creator content analytics
    function getCreatorAnalytics(
        address _creator
    ) external view returns (AppLibrary.CreatorAnalytics memory);

    //track tips
    function trackTip(address _creator, uint256 _amount) external;

    function getUserBadges(
        address _user
    ) external view returns (string[] memory);
}
