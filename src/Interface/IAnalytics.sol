// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/AppLibrary.sol";

interface IAnalytics {
    // Track Free content likes
    function trackFreeLike(uint256 _id) external;

    // Track Free content dislikes
    function trackFreeDislike(uint256 _id) external;

    // Track Free content ratings
    function trackFreeRating(uint256 _id, uint256 _rating) external;

    // Track Creator rating
    function trackCreatorRating(address _creator, uint256 _rating) external;

    // Track analytics
    function trackFollower(address _creator, bool inc) external;

    // Get Free content analytics
    function getFreeContentAnalytics(uint256 _id) external view returns(AppLibrary.ContentAnalytics memory);

    // Get creator content analytics
    function getCreatorAnalytics(address _creator) external view returns(AppLibrary.CreatorAnalytics memory);
}
