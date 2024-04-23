// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Analytics {
    mapping(uint256 => uint256) public views;
    mapping(uint256 => uint256) public likes;
    mapping(uint256 => uint256) public ratings;

    // Track content views
    function trackView(uint256 _id) external {
        views[_id]++;
    }

    // Track content likes
    function trackLike(uint256 _id) external {
        likes[_id]++;
    }

    // Track content ratings
    function trackRating(uint256 _id, uint256 _rating) external {
        ratings[_id] += _rating;
    }
}
