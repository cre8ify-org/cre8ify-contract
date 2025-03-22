// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library AnalyticsLibrary {
    event FreeContentLiked(
        uint256 indexed freeContentID,
        address indexed creator,
        uint256 indexed timestamp
    );
    event FreeContentDisliked(
        uint256 indexed freeContentID,
        address indexed creator,
        uint256 indexed timestamp
    );
    event FreeContentRated(
        uint256 indexed id,
        address indexed creator,
        uint256 indexed timestamp,
        uint256 rating
    );
    event CreatorRated(
        address indexed creator,
        uint256 indexed timestamp,
        uint256 rating
    );
    event TipTracked(
        address indexed creator,
        uint256 amount,
        uint256 timestamp
    );
    event BadgeAwarded(address indexed user, string badge, uint256 timestamp);

    // Commented out exclusive content events
    // event ExclusiveContentLiked(
    //     uint256 indexed exclusiveContentID,
    //     address indexed creator,
    //     uint256 indexed timestamp
    // );
    // event ExclusiveContentDisliked(
    //     uint256 indexed exclusiveContentID,
    //     address indexed creator,
    //     uint256 indexed timestamp
    // );
    // event ExclusiveContentRated(
    //     uint256 indexed id,
    //     address indexed creator,
    //     uint256 indexed timestamp,
    //     uint256 rating
    // );

    // Added back engagement functions
    function followCreator(
        address _creator,
        LayoutLibrary.CCPLayout storage appVars
    ) external {
        if (appVars.creatorFollowerTracker[_creator][msg.sender]) {
            return;
        }

        uint256 countId = appVars.creatorFollowerCount[_creator];
        appVars.creatorFollowerToCountMapping[_creator][msg.sender] = countId;
        appVars.creatorFollowerTracker[_creator][msg.sender] = true;
        AppLibrary.User memory follower = appVars
            .authorizationContract
            .getUserDetails(msg.sender);
        appVars.creatorFollowerArray[_creator].push(follower);
        appVars.creatorFollowerCount[_creator]++;
        appVars.analyticsContract.trackFollower(_creator, true);
    }

    function unFollowCreator(
        address _creator,
        LayoutLibrary.CCPLayout storage appVars
    ) public {
        if (!appVars.creatorFollowerTracker[_creator][msg.sender]) {
            return;
        }

        uint256 countId = appVars.creatorFollowerToCountMapping[_creator][
            msg.sender
        ];
        appVars.creatorFollowerTracker[_creator][msg.sender] = false;
        AppLibrary.User memory lastFollower = appVars.creatorFollowerArray[
            _creator
        ][appVars.creatorFollowerArray[_creator].length - 1];
        appVars.creatorFollowerArray[_creator][countId] = lastFollower;
        appVars.creatorFollowerToCountMapping[_creator][
            lastFollower.walletAddress
        ] = countId;
        appVars.creatorFollowerArray[_creator].pop();
        appVars.creatorFollowerCount[_creator]--;
        appVars.analyticsContract.trackFollower(_creator, false);
    }

    // Track tipping events
    function trackTip(
        address _creator,
        uint256 _amount,
        LayoutLibrary.CCPLayout storage appVars
    ) external {
        appVars.totalTips[_creator] += _amount;
        emit TipTracked(_creator, _amount, block.timestamp);
        _checkAndAwardBadges(_creator, appVars);
    }

    // Check and award badges based on tipping activity
    function _checkAndAwardBadges(
        address _creator,
        LayoutLibrary.CCPLayout storage appVars
    ) internal {
        // Example badge logic (customize as needed)
        if (
            appVars.totalTips[_creator] >= 1 ether &&
            !_hasBadge(_creator, "Bronze Tipper", appVars)
        ) {
            appVars.userBadges[_creator].push("Bronze Tipper");
            emit BadgeAwarded(_creator, "Bronze Tipper", block.timestamp);
        }
        if (
            appVars.totalTips[_creator] >= 5 ether &&
            !_hasBadge(_creator, "Silver Tipper", appVars)
        ) {
            appVars.userBadges[_creator].push("Silver Tipper");
            emit BadgeAwarded(_creator, "Silver Tipper", block.timestamp);
        }
        if (
            appVars.totalTips[_creator] >= 10 ether &&
            !_hasBadge(_creator, "Gold Tipper", appVars)
        ) {
            appVars.userBadges[_creator].push("Gold Tipper");
            emit BadgeAwarded(_creator, "Gold Tipper", block.timestamp);
        }
    }

    // Check if a user already has a badge
    function _hasBadge(
        address _user,
        string memory _badgeName,
        LayoutLibrary.CCPLayout storage appVars
    ) internal view returns (bool) {
        for (uint256 i = 0; i < appVars.userBadges[_user].length; i++) {
            if (
                keccak256(bytes(appVars.userBadges[_user][i])) ==
                keccak256(bytes(_badgeName))
            ) {
                return true;
            }
        }
        return false;
    }

    function likeFreeContent(
        uint256 _id,
        LayoutLibrary.CCPLayout storage appVars
    ) public {
        AppLibrary.ContentItem memory content = appVars.freeContents[_id];

        if (appVars.freeContentDislikeTracker[_id][msg.sender]) {
            appVars.freeContentsArray[_id].dislikes--;
            appVars.freeContents[_id].dislikes--;
            appVars
            .creatorFreeContents[content.creator][content.contentId].dislikes--;
            appVars.freeContentDislikeTracker[_id][msg.sender] = false;
        }

        if (!appVars.freeContentLikeTracker[_id][msg.sender]) {
            appVars.freeContentLikeTracker[_id][msg.sender] = true;
            appVars.freeContentsArray[_id].likes++;
            appVars.freeContents[_id].likes++;
            appVars
            .creatorFreeContents[content.creator][content.contentId].likes++;

            emit FreeContentLiked(_id, content.creator, block.timestamp);
            appVars.analyticsContract.trackFreeLike(_id);
        }
    }

    function dislikeFreeContent(
        uint256 _id,
        LayoutLibrary.CCPLayout storage appVars
    ) public {
        AppLibrary.ContentItem memory content = appVars.freeContents[_id];

        if (appVars.freeContentLikeTracker[_id][msg.sender]) {
            appVars.freeContentsArray[_id].likes--;
            appVars.freeContents[_id].likes--;
            appVars
            .creatorFreeContents[content.creator][content.contentId].likes--;
            appVars.freeContentLikeTracker[_id][msg.sender] = false;
        }

        if (!appVars.freeContentDislikeTracker[_id][msg.sender]) {
            appVars.freeContentDislikeTracker[_id][msg.sender] = true;
            appVars.freeContentsArray[_id].dislikes++;
            appVars.freeContents[_id].dislikes++;
            appVars
            .creatorFreeContents[content.creator][content.contentId].dislikes++;
            emit FreeContentDisliked(_id, content.creator, block.timestamp);
            appVars.analyticsContract.trackFreeDislike(_id);
        }
    }

    // Commented out exclusive content engagement
    // function likeExclusiveContent(uint256 _id, address _creator, LayoutLibrary.CCPLayout storage appVars) public {
    //     require(appVars.subscriptionContract.checkSubscribtionToCreatorStatus(_creator, msg.sender), "You are not subscribed");
    //     AppLibrary.ContentItem memory content = appVars.exclusiveContents[_creator][_id];
    //     if (appVars.exclusiveContentDislikeTracker[_id][msg.sender]) {
    //         appVars.creatorExclusiveContents[_creator][_id].dislikes--;
    //         appVars.exclusiveContents[_creator][_id].dislikes--;
    //         appVars.exclusiveContentDislikeTracker[_id][msg.sender] = false;
    //     }
    //
    //     if (!appVars.exclusiveContentLikeTracker[_id][msg.sender]) {
    //         appVars.exclusiveContentLikeTracker[_id][msg.sender] = true;
    //         appVars.creatorExclusiveContents[_creator][_id].likes++;
    //         appVars.exclusiveContents[_creator][_id].likes++;
    //         emit ExclusiveContentLiked(_id, content.creator, block.timestamp);
    //         appVars.analyticsContract.trackExclusiveLike(_id);
    //     }
    // }
    //
    // function dislikeExclusiveContent(uint256 _id, address _creator, LayoutLibrary.CCPLayout storage appVars) public {
    //     require(appVars.subscriptionContract.checkSubscribtionToCreatorStatus(_creator, msg.sender), "You are not subscribed");
    //     AppLibrary.ContentItem memory content = appVars.exclusiveContents[_creator][_id];
    //     if (appVars.exclusiveContentLikeTracker[_id][msg.sender]) {
    //         appVars.creatorExclusiveContents[_creator][_id].likes--;
    //         appVars.exclusiveContents[_creator][_id].likes--;
    //         appVars.exclusiveContentLikeTracker[_id][msg.sender] = false;
    //     }
    //
    //     if (!appVars.exclusiveContentDislikeTracker[_id][msg.sender]) {
    //         appVars.exclusiveContentDislikeTracker[_id][msg.sender] = true;
    //         appVars.creatorExclusiveContents[_creator][_id].dislikes++;
    //         appVars.exclusiveContents[_creator][_id].dislikes++;
    //         emit ExclusiveContentDisliked(_id, content.creator, block.timestamp);
    //         appVars.analyticsContract.trackExclusiveDislike(_id);
    //     }
    // }

    function rateFreeContent(
        uint256 _id,
        uint _rating,
        LayoutLibrary.CCPLayout storage appVars
    ) public {
        require(_rating >= 1 && _rating <= 5, "Invalid rating");
        uint256 previousRating = appVars.userFreeContentRatingTracker[_id][
            msg.sender
        ];
        if (!(previousRating < 1)) {
            appVars.freeContentRatingSum[_id] -= previousRating;
            appVars.freeContentRatingCount[_id] -= 1;
        }

        appVars.freeContentRatingSum[_id] += _rating;
        appVars.freeContentRatingCount[_id] += 1;
        uint256 averageRating = (appVars.freeContentRatingSum[_id] /
            appVars.freeContentRatingCount[_id]) * 1 ether;
        AppLibrary.ContentItem memory content = appVars.freeContents[_id];

        appVars.freeContentsArray[_id].rating = averageRating;
        appVars.freeContents[_id].rating = averageRating;
        appVars
        .creatorFreeContents[content.creator][content.contentId]
            .rating = averageRating;
        appVars.userFreeContentRatingTracker[_id][msg.sender] = _rating;
        emit FreeContentRated(_id, content.creator, block.timestamp, _rating);
        appVars.analyticsContract.trackFreeRating(_id, averageRating);
    }

    // Commented out exclusive content rating
    // function rateExclusiveContent(uint256 _id, address _creator, uint256 _rating, LayoutLibrary.CCPLayout storage appVars) public {
    //     require(appVars.subscriptionContract.checkSubscribtionToCreatorStatus(_creator, msg.sender), "You are not subscribed");
    //     require(_rating >= 1 && _rating <= 5, "Invalid rating");
    //     uint256 previousRating = appVars.userExclusiveContentRatingTracker[_id][msg.sender];
    //
    //     if (!(previousRating < 1)) {
    //         appVars.exclusiveContentRatingSum[_creator][_id] -= previousRating;
    //         appVars.exclusiveContentRatingCount[_creator][_id] -= 1;
    //     }
    //
    //     appVars.exclusiveContentRatingSum[_creator][_id] += _rating;
    //     appVars.exclusiveContentRatingCount[_creator][_id] += 1;
    //
    //     uint256 averageRating = (appVars.exclusiveContentRatingSum[_creator][_id] / appVars.exclusiveContentRatingCount[_creator][_id]) * 1 ether;
    //     AppLibrary.ContentItem memory content = appVars.exclusiveContents[_creator][_id];
    //     appVars.creatorExclusiveContents[_creator][_id].rating = averageRating;
    //     appVars.exclusiveContents[_creator][_id].rating = averageRating;
    //     appVars.userExclusiveContentRatingTracker[_id][msg.sender] = _rating;
    //     emit ExclusiveContentRated(_id, content.creator, block.timestamp, _rating);
    //     appVars.analyticsContract.trackExclusiveRating(_id, averageRating);
    // }

    function rateCreator(
        address creator,
        uint _rating,
        LayoutLibrary.CCPLayout storage appVars
    ) public {
        require(_rating >= 1 && _rating <= 5, "Invalid rating");
        uint256 previousRating = appVars.userCreatorRatings[creator][
            msg.sender
        ];

        if (!(previousRating < 1)) {
            appVars.creatorRatingSum[creator] -= previousRating;
            appVars.creatorRatingCount[creator] -= 1;
        }

        appVars.userCreatorRatings[creator][msg.sender] = _rating;
        appVars.creatorRatingSum[creator] += _rating;
        appVars.creatorRatingCount[creator] += 1;
        uint256 averageRating = (appVars.creatorRatingSum[creator] /
            appVars.creatorRatingCount[creator]) * 1 ether;

        appVars.creatorRating[creator] = averageRating;
        appVars.analyticsContract.trackCreatorRating(creator, averageRating);
        emit CreatorRated(creator, block.timestamp, _rating);
    }

    function getFollowers(
        address _creator,
        LayoutLibrary.CCPLayout storage appVars
    ) public view returns (AppLibrary.User[] memory) {
        return appVars.creatorFollowerArray[_creator];
    }

    function getFreeContentAnalytics(
        uint256 _id,
        LayoutLibrary.AnalyticsLayout storage analyticsVars
    ) public view returns (AppLibrary.ContentAnalytics memory) {
        AppLibrary.ContentAnalytics memory contentAnalytics = AppLibrary
            .ContentAnalytics(
                analyticsVars.freeLikes[_id],
                analyticsVars.freeDislikes[_id],
                analyticsVars.freeRatings[_id]
            );
        return contentAnalytics;
    }

    // Commented out exclusive content analytics
    // function getExclusiveContentAnalytics(uint256 _id, LayoutLibrary.AnalyticsLayout storage analyticsVars) public view returns(AppLibrary.ContentAnalytics memory) {
    //     AppLibrary.ContentAnalytics memory contentAnalytics = AppLibrary.ContentAnalytics(
    //         analyticsVars.exclusiveLikes[_id],
    //         analyticsVars.exclusiveDislikes[_id],
    //         analyticsVars.exclusiveRatings[_id]
    //     );
    //     return contentAnalytics;
    // }

    function getCreatorAnalytics(
        address _creator,
        LayoutLibrary.AnalyticsLayout storage analyticsVars
    ) public view returns (AppLibrary.CreatorAnalytics memory) {
        AppLibrary.CreatorAnalytics memory creatorAnalytics = AppLibrary
            .CreatorAnalytics(
                analyticsVars.creatorRatings[_creator],
                analyticsVars.follower[_creator]
            );
        return creatorAnalytics;
    }

    // Fetch top tippers
    function getTopTippers(
        uint256 _limit,
        LayoutLibrary.CCPLayout storage appVars
    ) external view returns (address[] memory, uint256[] memory) {
        address[] memory tippers = new address[](_limit);
        uint256[] memory amounts = new uint256[](_limit);

        // Placeholder logic (replace with actual implementation)
        for (uint256 i = 0; i < _limit; i++) {
            tippers[i] = address(uint160(i));
            amounts[i] = appVars.totalTips[tippers[i]];
        }

        return (tippers, amounts);
    }

    // Fetch top creators
    function getTopCreators(
        uint256 _limit,
        LayoutLibrary.CCPLayout storage appVars
    ) external view returns (address[] memory, uint256[] memory) {
        address[] memory creators = new address[](_limit);
        uint256[] memory amounts = new uint256[](_limit);

        // Placeholder logic (replace with actual implementation)
        for (uint256 i = 0; i < _limit; i++) {
            creators[i] = address(uint160(i));
            amounts[i] = appVars.totalTips[creators[i]];
        }

        return (creators, amounts);
    }

    function trackFreeLike(
        uint256 _id,
        LayoutLibrary.AnalyticsLayout storage analyticsVars
    ) external {
        analyticsVars.freeLikes[_id]++;
    }

    function trackFreeDislike(
        uint256 _id,
        LayoutLibrary.AnalyticsLayout storage analyticsVars
    ) external {
        analyticsVars.freeDislikes[_id]++;
    }

    function trackFreeRating(
        uint256 _id,
        uint256 _rating,
        LayoutLibrary.AnalyticsLayout storage analyticsVars
    ) external {
        analyticsVars.freeRatings[_id] = _rating;
    }

    // Commented out exclusive content tracking
    // function trackExclusiveLike(uint256 _id, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
    //     analyticsVars.exclusiveLikes[_id]++;
    // }
    //
    // function trackExclusiveDislike(uint256 _id, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
    //     analyticsVars.exclusiveDislikes[_id]++;
    // }
    //
    // function trackExclusiveRating(uint256 _id, uint256 _rating, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
    //     analyticsVars.exclusiveRatings[_id] = _rating;
    // }

    function trackCreatorRating(
        address _creator,
        uint256 _rating,
        LayoutLibrary.AnalyticsLayout storage analyticsVars
    ) external {
        analyticsVars.creatorRatings[_creator] = _rating;
    }

    function trackFollower(
        address _creator,
        bool inc,
        LayoutLibrary.AnalyticsLayout storage analyticsVars
    ) external {
        if (inc) {
            analyticsVars.follower[_creator]++;
        } else {
            analyticsVars.follower[_creator]--;
        }
    }
}
