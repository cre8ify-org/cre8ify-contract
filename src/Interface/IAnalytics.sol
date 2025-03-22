// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/AppLibrary.sol";

interface IAnalytics {
    /**
     * @notice Track likes for a free content item
     * @param _id The ID of the content
     */
    function trackFreeLike(uint256 _id) external;

    /**
     * @notice Track dislikes for a free content item
     * @param _id The ID of the content
     */
    function trackFreeDislike(uint256 _id) external;

    /**
     * @notice Track ratings for a free content item
     * @param _id The ID of the content
     * @param _rating The rating value (e.g., 1-5 stars)
     */
    function trackFreeRating(uint256 _id, uint256 _rating) external;

    /**
     * @notice Track a creator's rating
     * @param _creator The address of the creator
     * @param _rating The rating value (e.g., 1-5 stars)
     */
    function trackCreatorRating(address _creator, uint256 _rating) external;

    /**
     * @notice Track follower changes for a creator
     * @param _creator The address of the creator
     * @param inc Whether to increment (`true`) or decrement (`false`) the follower count
     */
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
