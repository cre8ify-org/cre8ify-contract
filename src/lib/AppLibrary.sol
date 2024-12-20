// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AppLibrary {
    struct User {
        string username;
        address walletAddress;
        string profileImage;
        uint256 totalTipsReceived; // Total tips received by the user
        string[] badges;           // Badges earned by the user
    }

    struct ContentItem {
        string title;
        uint256 id;
        uint256 contentId;
        uint256 dateCreated;
        string creatorProfile;
        string ipfsHash;
        address creator;
        uint256 views;
        uint256 likes;
        uint256 dislikes;
        uint256 shares;
        uint256 rating;
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
        uint256 amount;  // Amount tipped
        uint256 timestamp; // Time of tipping
    }
}
