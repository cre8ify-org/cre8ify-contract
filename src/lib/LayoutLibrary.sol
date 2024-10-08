// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

        mapping(address => AppLibrary.ContentItem[]) creatorExclusiveContents;
        mapping(address => uint256) creatorExclusiveContentCount;
        mapping(address => mapping(uint256 => AppLibrary.ContentItem)) exclusiveContents;

        mapping(address => AppLibrary.User[]) creatorFollowerArray;
        mapping(address => uint256) creatorFollowerCount;
        mapping(address => mapping(address => uint256)) creatorFollowerToCountMapping;
        mapping(address => mapping(address => bool)) creatorFollowerTracker;  

        mapping(uint256 => mapping(address => uint256)) userFreeContentRatingTracker;
        mapping(uint256 => mapping(address => uint256)) userExclusiveContentRatingTracker;

        mapping(uint256 => uint256) freeContentRatingSum;
        mapping(address => mapping(uint256 => uint256)) exclusiveContentRatingSum;

        mapping(uint256 => uint256) freeContentRatingCount;
        mapping(address => mapping(uint256 => uint256)) exclusiveContentRatingCount;

        mapping(uint256 => mapping(address => bool)) freeContentLikeTracker;
        mapping(uint256 => mapping(address => bool)) exclusiveContentLikeTracker;

        mapping(uint256 => mapping(address => bool)) freeContentDislikeTracker;
        mapping(uint256 => mapping(address => bool)) exclusiveContentDislikeTracker;

        mapping(address => uint256) fetchExclusiveContentTimestamp;

        mapping(address => uint256) creatorRating;
        mapping(address => uint256) creatorRatingSum;
        mapping(address => uint256) creatorRatingCount;
        mapping(address => mapping(address => uint256)) userCreatorRatings;

        IAuthorization authorizationContract;
        IAnalytics analyticsContract;
        ISubscription subscriptionContract;
    }

    struct AnalyticsLayout{
        mapping(uint256 => uint256)  freeLikes;
        mapping(uint256 => uint256)  freeDislikes;
        mapping(uint256 => uint256)  freeRatings;
        mapping(uint256 => uint256)  exclusiveLikes;
        mapping(uint256 => uint256)  exclusiveDislikes;
        mapping(uint256 => uint256)  exclusiveRatings;
        mapping(address => uint256)  follower;
        mapping(address => uint256)  creatorRatings;

        address ccpContract;
        address owner;
    }

    struct AuthorizationLayout{
        uint256 userCount;
        mapping(address => AppLibrary.User) userDetails;
        mapping(address => bool) registeredUsers;
        mapping(string => address) usernameAddressTracker;
        mapping(address => uint256) userIndexTracker;
        AppLibrary.User[] registeredUsersArray; 
    }

    struct SubscriptionLayout{
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

    struct VaultLayout{
        uint256 subscriptionBalances;
        mapping(address => uint256) creatorAccured;

        IERC20 token;
    }
}