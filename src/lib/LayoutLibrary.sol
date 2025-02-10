// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interface/IAuthorization.sol";
import "../interface/IAnalytics.sol";
import "../interface/ITipping.sol";
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
        mapping(address => AppLibrary.User[]) creatorFollowerArray;
        mapping(address => uint256) creatorFollowerCount;
        mapping(address => mapping(address => uint256)) creatorFollowerToCountMapping;
        mapping(address => mapping(address => bool)) creatorFollowerTracker;
        mapping(uint256 => mapping(address => uint256)) userFreeContentRatingTracker;
        mapping(uint256 => uint256) freeContentRatingSum;
        mapping(uint256 => uint256) freeContentRatingCount;
        mapping(uint256 => mapping(address => bool)) freeContentLikeTracker;
        mapping(uint256 => mapping(address => bool)) freeContentDislikeTracker;
        mapping(address => uint256) creatorRating;
        mapping(address => uint256) creatorRatingSum;
        mapping(address => uint256) creatorRatingCount;
        mapping(address => mapping(address => uint256)) userCreatorRatings;
        mapping(address => uint256) totalTips;
        mapping(address => AppLibrary.User[]) creatorTippers;
        mapping(address => mapping(address => uint256)) tipperAmounts;
        IAuthorization authorizationContract;
        IAnalytics analyticsContract;
        ITippingSystem tippingSystemContract;
    }

    struct AnalyticsLayout {
        mapping(uint256 => uint256) freeLikes;
        mapping(uint256 => uint256) freeDislikes;
        mapping(uint256 => uint256) freeRatings;
        mapping(address => uint256) follower;
        mapping(address => uint256) creatorRatings;
        address ccpContract;
        address owner;
    }

    struct AuthorizationLayout {
        uint256 userCount;
        mapping(address => AppLibrary.User) userDetails;
        mapping(address => bool) registeredUsers;
        mapping(string => address) usernameAddressTracker;
        mapping(address => uint256) userIndexTracker;
        AppLibrary.User[] registeredUsersArray;
    }

    struct VaultLayout {
        mapping(address => uint256) creatorAccrued;
        uint256 tippingBalances;
        IERC20 token;
    }

    struct ContentDiscoveryLayout {
        address ccpContract;
        IAuthorization authorizationContract;
        mapping(uint256 => AppLibrary.ContentItem) freeContents;
        mapping(address => AppLibrary.User) creators;
        mapping(uint256 => uint256) contentLikes;
        mapping(uint256 => uint256) contentRatings;
        mapping(address => uint256) userPreferences;
    }
}
