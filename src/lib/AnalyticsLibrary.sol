// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library AnalyticsLibrary {

    event FreeContentLiked(uint256 indexed freeContentID, address indexed creator, uint256 indexed timestamp);
    event FreeContentDisliked(uint256 indexed freeContentID, address indexed creator, uint256 indexed timestamp);
    event FreeContentViewed(uint256 indexed id, address indexed creator, uint256 indexed timestamp);
    event FreeContentRated(uint256 indexed id, address indexed creator, uint256 indexed timestamp, uint256 rating);
    event CreatorRated(address indexed creator, uint256 indexed timestamp, uint256 rating);
    event TipGiven(address indexed giver, address indexed creator, uint256 amount, uint256 timestamp);

    struct TippingLeaderboard {
        address[] topTippers;
        address[] topCreators;
    }

    mapping(address => uint256) public tippingBalances;
    mapping(address => uint256) public creatorTips;

    function followCreator(address _creator, LayoutLibrary.CCPLayout storage appVars) external {
        if (appVars.creatorFollowerTracker[_creator][msg.sender]) {
            return;
        }

        uint256 countId = appVars.creatorFollowerCount[_creator];

        appVars.creatorFollowerToCountMapping[_creator][msg.sender] = countId;
        appVars.creatorFollowerTracker[_creator][msg.sender] = true;

        AppLibrary.User memory follower = appVars.authorizationContract.getUserDetails(msg.sender);
        appVars.creatorFollowerArray[_creator].push(follower);
        appVars.creatorFollowerCount[_creator]++;

        appVars.analyticsContract.trackFollower(_creator, true);
    }

    function unFollowCreator(address _creator, LayoutLibrary.CCPLayout storage appVars) public {
        if (!appVars.creatorFollowerTracker[_creator][msg.sender]) {
            return;
        }

        uint256 countId = appVars.creatorFollowerToCountMapping[_creator][msg.sender];
        appVars.creatorFollowerTracker[_creator][msg.sender] = false;

        AppLibrary.User memory lastFollower = appVars.creatorFollowerArray[_creator][appVars.creatorFollowerArray[_creator].length - 1];
        appVars.creatorFollowerArray[_creator][countId] = lastFollower;
        appVars.creatorFollowerToCountMapping[_creator][lastFollower.walletAddress] = countId;
        appVars.creatorFollowerArray[_creator].pop();
        appVars.creatorFollowerCount[_creator]--;

        appVars.analyticsContract.trackFollower(_creator, false);
    }

    function likeFreeContent(uint256 _id, LayoutLibrary.CCPLayout storage appVars) public {
        AppLibrary.ContentItem memory content = appVars.freeContents[_id];

        if (appVars.freeContentDislikeTracker[_id][msg.sender]) {
            appVars.freeContentsArray[_id].dislikes--;
            appVars.freeContents[_id].dislikes--;
            appVars.creatorFreeContents[content.creator][content.contentId].dislikes--;
            appVars.freeContentDislikeTracker[_id][msg.sender] = false;
        }

        if (!appVars.freeContentLikeTracker[_id][msg.sender]) {
            appVars.freeContentLikeTracker[_id][msg.sender] = true;
            appVars.freeContentsArray[_id].likes++;
            appVars.freeContents[_id].likes++;
            appVars.creatorFreeContents[content.creator][content.contentId].likes++;

            emit FreeContentLiked(_id, content.creator, block.timestamp);
            appVars.analyticsContract.trackFreeLike(_id);
        }
    }

    function dislikeFreeContent(uint256 _id, LayoutLibrary.CCPLayout storage appVars) public {
        AppLibrary.ContentItem memory content = appVars.freeContents[_id];

        if (appVars.freeContentLikeTracker[_id][msg.sender]) {
            appVars.freeContentsArray[_id].likes--;
            appVars.freeContents[_id].likes--;
            appVars.creatorFreeContents[content.creator][content.contentId].likes--;
            appVars.freeContentLikeTracker[_id][msg.sender] = false;
        }

        if (!appVars.freeContentDislikeTracker[_id][msg.sender]) {
            appVars.freeContentDislikeTracker[_id][msg.sender] = true;
            appVars.freeContentsArray[_id].dislikes++;
            appVars.freeContents[_id].dislikes++;
            appVars.creatorFreeContents[content.creator][content.contentId].dislikes++;

            emit FreeContentDisliked(_id, content.creator, block.timestamp);
            appVars.analyticsContract.trackFreeDislike(_id);
        }
    }

    function rateFreeContent(uint256 _id, uint256 _rating, LayoutLibrary.CCPLayout storage appVars) public {
        require(_rating >= 1 && _rating <= 5, "Invalid rating");

        uint256 previousRating = appVars.userFreeContentRatingTracker[_id][msg.sender];

        if (previousRating > 0) {
            appVars.freeContentRatingSum[_id] -= previousRating;
            appVars.freeContentRatingCount[_id] -= 1;
        }

        appVars.freeContentRatingSum[_id] += _rating;
        appVars.freeContentRatingCount[_id] += 1;

        uint256 averageRating = (appVars.freeContentRatingSum[_id] / appVars.freeContentRatingCount[_id]) * 1 ether;

        AppLibrary.ContentItem memory content = appVars.freeContents[_id];

        appVars.freeContentsArray[_id].rating = averageRating;
        appVars.freeContents[_id].rating = averageRating;
        appVars.creatorFreeContents[content.creator][content.contentId].rating = averageRating;

        appVars.userFreeContentRatingTracker[_id][msg.sender] = _rating;

        emit FreeContentRated(_id, content.creator, block.timestamp, _rating);
        appVars.analyticsContract.trackFreeRating(_id, averageRating);
    }

    function rateCreator(address creator, uint256 _rating, LayoutLibrary.CCPLayout storage appVars) public {
        require(_rating >= 1 && _rating <= 5, "Invalid rating");

        uint256 previousRating = appVars.userCreatorRatings[creator][msg.sender];

        if (previousRating > 0) {
            appVars.creatorRatingSum[creator] -= previousRating;
            appVars.creatorRatingCount[creator] -= 1;
        }

        appVars.userCreatorRatings[creator][msg.sender] = _rating;
        appVars.creatorRatingSum[creator] += _rating;
        appVars.creatorRatingCount[creator] += 1;

        uint256 averageRating = (appVars.creatorRatingSum[creator] / appVars.creatorRatingCount[creator]) * 1 ether;

        appVars.creatorRating[creator] = averageRating;
        appVars.analyticsContract.trackCreatorRating(creator, averageRating);

        emit CreatorRated(creator, block.timestamp, _rating);
    }

    function tipCreator(address _creator, uint256 _amount, LayoutLibrary.CCPLayout storage appVars) public {
        require(_amount > 0, "Amount must be greater than zero");

        tippingBalances[msg.sender] -= _amount;
        creatorTips[_creator] += _amount;

        emit TipGiven(msg.sender, _creator, _amount, block.timestamp);
    }

    function getFollowers(address _creator, LayoutLibrary.CCPLayout storage appVars) public view returns (AppLibrary.User[] memory) {
        return appVars.creatorFollowerArray[_creator];
    }

    function trackFreeLike(uint256 _id, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
        analyticsVars.freeLikes[_id]++;
    }

    function trackFreeDislike(uint256 _id, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
        analyticsVars.freeDislikes[_id]++;
    }

    function trackFreeRating(uint256 _id, uint256 _rating, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
        analyticsVars.freeRatings[_id] = _rating;
    }

    function trackCreatorRating(address _creator, uint256 _rating, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
        analyticsVars.creatorRatings[_creator] = _rating;
    }

    function trackFollower(address _creator, bool inc, LayoutLibrary.AnalyticsLayout storage analyticsVars) external {
        if (inc) {
            analyticsVars.follower[_creator]++;
        } else {
            analyticsVars.follower[_creator]--;
        }
    }
}
