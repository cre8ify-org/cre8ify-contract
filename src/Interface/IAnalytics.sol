// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    /**
     * @notice Retrieve analytics data for a specific free content item
     * @param _id The ID of the content
     * @return AppLibrary.ContentAnalytics The analytics data for the content
     */
    function getFreeContentAnalytics(uint256 _id) external view returns (AppLibrary.ContentAnalytics memory);

    /**
     * @notice Retrieve analytics data for a specific creator
     * @param _creator The address of the creator
     * @return AppLibrary.CreatorAnalytics The analytics data for the creator
     */
    function getCreatorAnalytics(address _creator) external view returns (AppLibrary.CreatorAnalytics memory);

    /**
     * @notice Get the total likes for a specific free content item
     * @param _id The ID of the content
     * @return uint256 The total number of likes
     */
    function getTotalLikes(uint256 _id) external view returns (uint256);

    /**
     * @notice Get the total dislikes for a specific free content item
     * @param _id The ID of the content
     * @return uint256 The total number of dislikes
     */
    function getTotalDislikes(uint256 _id) external view returns (uint256);

    /**
     * @notice Get the total followers for a specific creator
     * @param _creator The address of the creator
     * @return uint256 The total number of followers
     */
    function getTotalFollowers(address _creator) external view returns (uint256);
}
