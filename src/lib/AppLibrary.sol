// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library AppLibrary {
    struct User {
        string username;
        address walletAddress;
        string profileImage;
        uint256 totalTipsReceived; // Total tips received by the user
        string[] badges; // Badges earned by the user
    }

    struct ContentItem {
        string title;
        uint256 id;
        uint256 contentId;
        uint256 dateCreated;
        address creator;
        string creatorProfile;
        string ipfsHash;
        uint256 views;
        uint256 likes;
        uint256 dislikes;
        uint256 shares;
        uint256 rating;
        string contentType;
        string creatorImage;
    }

    struct ContentAnalytics {
        uint256 likes;
        uint256 dislikes;
        uint256 rating;
    }

    struct CreatorAnalytics {
        uint256 rating;
        uint256 followersCount;
    }

    struct TippingInfo {
        address tipper;
        uint256 amount;
        uint256 timestamp;
    }

    struct Badge {
        string name;
        uint256 threshold;
    }
}
