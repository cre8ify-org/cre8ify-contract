// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../interface/IAuthorization.sol";
import "../interface/IAnalytics.sol";
import "../interface/ISubscription.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interface/IVault.sol";
import "./AppLibrary.sol";

library LayoutLibrary {
    struct CCPLayout {
        uint256 freeContentCount;
        AppLibrary.ContentItem[] freeContentsArray;
        mapping(address => AppLibrary.ContentItem[]) creatorFreeContents;
        mapping(address => uint256) creatorFreeContentCount;
        mapping(uint256 => AppLibrary.ContentItem) freeContents;
        // Commented out exclusive content storage
        // mapping(address => AppLibrary.ContentItem[]) creatorExclusiveContents;
        // mapping(address => uint256) creatorExclusiveContentCount;
        // mapping(address => mapping(uint256 => AppLibrary.ContentItem)) exclusiveContents;

        // Added back engagement storage
        mapping(address => AppLibrary.User[]) creatorFollowerArray;
        mapping(address => uint256) creatorFollowerCount;
        mapping(address => mapping(address => uint256)) creatorFollowerToCountMapping;
        mapping(address => mapping(address => bool)) creatorFollowerTracker;
        mapping(uint256 => mapping(address => uint256)) userFreeContentRatingTracker;
        // Commented out exclusive content rating
        // mapping(uint256 => mapping(address => uint256)) userExclusiveContentRatingTracker;

        mapping(uint256 => uint256) freeContentRatingSum;
        // Commented out exclusive content rating sum
        // mapping(address => mapping(uint256 => uint256)) exclusiveContentRatingSum;

        mapping(uint256 => uint256) freeContentRatingCount;
        // Commented out exclusive content rating count
        // mapping(address => mapping(uint256 => uint256)) exclusiveContentRatingCount;

        mapping(uint256 => mapping(address => bool)) freeContentLikeTracker;
        // Commented out exclusive content like tracker
        // mapping(uint256 => mapping(address => bool)) exclusiveContentLikeTracker;

        mapping(uint256 => mapping(address => bool)) freeContentDislikeTracker;
        // Commented out exclusive content dislike tracker
        // mapping(uint256 => mapping(address => bool)) exclusiveContentDislikeTracker;

        // Commented out exclusive content timestamp
        // mapping(address => uint256) fetchExclusiveContentTimestamp;

        mapping(address => uint256) creatorRating;
        mapping(address => uint256) creatorRatingSum;
        mapping(address => uint256) creatorRatingCount;
        mapping(address => mapping(address => uint256)) userCreatorRatings;
        // Added for tipping feature
        mapping(address => uint256) totalTips;
        mapping(address => string[]) userBadges;
        IAuthorization authorizationContract;
        IAnalytics analyticsContract;
        ISubscription subscriptionContract;
    }

    struct AnalyticsLayout {
        mapping(uint256 => uint256) freeLikes;
        mapping(uint256 => uint256) freeDislikes;
        mapping(uint256 => uint256) freeRatings;
        // Commented out exclusive content analytics
        // mapping(uint256 => uint256) exclusiveLikes;
        // mapping(uint256 => uint256) exclusiveDislikes;
        // mapping(uint256 => uint256) exclusiveRatings;
        mapping(address => uint256) follower;
        mapping(address => uint256) creatorRatings;
        mapping(address => uint256) creatorTips;
        mapping(address => string[]) userBadges;
        address ccpContract;
        address owner;
    }

    // Other layouts remain unchanged
    struct AuthorizationLayout {
        uint256 userCount;
        mapping(address => AppLibrary.User) userDetails;
        mapping(address => bool) registeredUsers;
        mapping(string => address) usernameAddressTracker;
        mapping(address => uint256) userIndexTracker;
        AppLibrary.User[] registeredUsersArray;
    }

    struct SubscriptionLayout {
        mapping(address => mapping(address => bool)) isSubscribedToCreator;
        mapping(address => mapping(address => uint256)) subscriptionToCreatorExpiry;
        mapping(address => AppLibrary.User[]) creatorSubscribers;
        mapping(address => AppLibrary.User[]) SubscribedTo;
        mapping(address => uint256) creatorSubscriptionAmount;
        mapping(address => bool) isSubscribed;
        mapping(address => uint256) subscriptionExpiry;
        IERC20 token;
        IVault vault;
        IAuthorization authorizationContract;
    }

    struct VaultLayout {
        uint256 subscriptionBalances;
        mapping(address => uint256) creatorAccured; // Tracks accrued tips for creators
        uint256 platformEarnings; // Tracks platform earnings from fees
        uint256 platformPercentage; // Platform fee percentage (e.g., 5 for 5%)
        address subscriptionContract;
        IERC20 token;
    }
}
