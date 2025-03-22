// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/AnalyticsLibrary.sol";
import "./lib/ContentLibrary.sol";

contract CCP {
    LayoutLibrary.CCPLayout internal appVars;

    // Events
    event FreeContentCreated(
        uint256 indexed contentId,
        address indexed creator,
        string title
    );
    event TipSent(
        address indexed tipper,
        address indexed creator,
        uint256 amount
    );
    event ContentDeleted(uint256 indexed contentId, address indexed creator);

    // Commented out exclusive content events
    // event ExclusiveContentCreated(
    //     uint256 indexed contentId,
    //     address indexed creator,
    //     string title
    // );
    // event ExclusiveContentDeleted(
    //     uint256 indexed contentId,
    //     address indexed creator
    // );

    constructor(
        address _authorization,
        address _analytic,
        address _subscription
    ) {
        appVars.authorizationContract = IAuthorization(_authorization);
        appVars.analyticsContract = IAnalytics(_analytic);
        appVars.subscriptionContract = ISubscription(_subscription);
    }

    modifier onlyRegistered() {
        require(
            appVars.authorizationContract.checkRegisteredUsers(msg.sender),
            "User is not registered"
        );
        _;
    }

    // Content creation and management functions
    function createFreeContent(
        string memory _title,
        string memory _ipfsHash,
        string memory _contentType,
        string memory username,
        string memory _creatorImage
    ) public onlyRegistered {
        uint256 contentId = ContentLibrary.createFreeContent(
            _title,
            _ipfsHash,
            _contentType,
            username,
            _creatorImage,
            appVars
        );
        emit FreeContentCreated(contentId, msg.sender, _title);
    }

    // Commented out exclusive content creation
    // function createExclusiveContent(
    //     string memory _title,
    //     string memory _ipfsHash,
    //     string memory _contentType,
    //     string memory username,
    //     string memory _creatorImage
    // ) public onlyRegistered {
    //     uint256 contentId = ContentLibrary.createExclusiveContent(
    //         _title,
    //         _ipfsHash,
    //         _contentType,
    //         username,
    //         _creatorImage,
    //         appVars
    //     );
    //     emit ExclusiveContentCreated(contentId, msg.sender, _title);
    // }

    function deleteFreeContent(uint256 _id) public onlyRegistered {
        ContentLibrary.deleteFreeContent(_id, appVars);
        emit ContentDeleted(_id, msg.sender);
    }

    // Commented out exclusive content deletion
    // function deleteExclusiveContent(uint256 _id) public onlyRegistered {
    //     ContentLibrary.deleteExclusiveContent(_id, appVars);
    //     emit ExclusiveContentDeleted(_id, msg.sender);
    // }

    // Fetch free content
    function fetchFreeContent()
        public
        view
        returns (AppLibrary.ContentItem[] memory)
    {
        return ContentLibrary.fetchFreeContent(appVars);
    }

    // Commented out exclusive content fetching
    // function fetchExclusiveContent(
    //     address _creator
    // ) public returns (AppLibrary.ContentItem[] memory) {
    //     return ContentLibrary.fetchExclusiveContent(_creator, appVars);
    // }

    // Fetch free content created by a specific creator
    function fetchMyFreeContent(
        address _creator
    ) public view returns (AppLibrary.ContentItem[] memory) {
        return ContentLibrary.fetchMyFreeContent(_creator, appVars);
    }

    // Commented out exclusive content fetching for creator
    // function fetchMyExclusiveContent()
    //     public
    //     returns (AppLibrary.ContentItem[] memory)
    // {
    //     return ContentLibrary.fetchMyExclusiveContent(appVars);
    // }

    // Added back engagement features
    function fetchFollowers(
        address _creator
    ) public view onlyRegistered returns (AppLibrary.User[] memory) {
        return AnalyticsLibrary.getFollowers(_creator, appVars);
    }

    // Interaction with Subscription contract for tipping
    function tipCreator(
        address _creator,
        uint256 amount
    ) public onlyRegistered {
        appVars.subscriptionContract.tipCreator(_creator, amount);
        appVars.analyticsContract.trackTip(_creator, amount);
        emit TipSent(msg.sender, _creator, amount);
    }

<<<<<<< HEAD
    // function fetchExclusiveContentAnalytics(uint256 _id) public view onlyRegistered returns(AppLibrary.ContentAnalytics memory){
        
    //     return ContentLibrary.fetchExclusiveContentAnalytics(_id, appVars);

    // }

    function fetchCreatorAnalytics(address _creator) public view onlyRegistered returns(AppLibrary.CreatorAnalytics memory){
        
=======
    // Interaction with Analytics contract
    // Fetch creator analytics
    function fetchCreatorAnalytics(
        address _creator
    ) public view returns (AppLibrary.CreatorAnalytics memory) {
>>>>>>> 5a26d08de02ce09a9aaf8efc5b0895d1836cc05b
        return ContentLibrary.fetchCreatorAnalytics(_creator, appVars);
    }

    // Fetch free content analytics
    function fetchFreeContentAnalytics(
        uint256 _id
    ) public view returns (AppLibrary.ContentAnalytics memory) {
        return ContentLibrary.fetchFreeContentAnalytics(_id, appVars);
    }

    // Commented out exclusive content analytics
    // function fetchExclusiveContentAnalytics(
    //     uint256 _id
    // ) public view onlyRegistered returns (AppLibrary.ContentAnalytics memory) {
    //     return ContentLibrary.fetchExclusiveContentAnalytics(_id, appVars);
    // }

    // Fetch badges for a user
    function getUserBadges(
        address _user
    ) public view returns (string[] memory) {
        return appVars.analyticsContract.getUserBadges(_user);
    }

    // Added back engagement functions
    function followCreator(address _creator) public onlyRegistered {
        AnalyticsLibrary.followCreator(_creator, appVars);
    }

    function unFollowCreator(address _creator) public onlyRegistered {
        AnalyticsLibrary.unFollowCreator(_creator, appVars);
    }

    // Like free content
    function likeFreeContent(uint256 _id) public {
        AnalyticsLibrary.likeFreeContent(_id, appVars);
    }

    function dislikeFreeContent(uint256 _id) public onlyRegistered {
        AnalyticsLibrary.dislikeFreeContent(_id, appVars);
    }

    // Commented out exclusive content engagement
    // function likeExclusiveContent(
    //     uint256 _id,
    //     address _creator
    // ) public onlyRegistered {
    //     AnalyticsLibrary.likeExclusiveContent(_id, _creator, appVars);
    // }

    // function dislikeExclusiveContent(
    //     uint256 _id,
    //     address _creator
    // ) public onlyRegistered {
    //     AnalyticsLibrary.dislikeExclusiveContent(_id, _creator, appVars);
    // }

    function rateFreeContent(uint256 _id, uint _rating) public onlyRegistered {
        AnalyticsLibrary.rateFreeContent(_id, _rating, appVars);
    }

    // Commented out exclusive content rating
    // function rateExclusiveContent(
    //     uint256 _id,
    //     address _creator,
    //     uint256 _rating
    // ) public onlyRegistered {
    //     AnalyticsLibrary.rateExclusiveContent(_id, _creator, _rating, appVars);
    // }

    function rateCreator(address _creator, uint _rating) public onlyRegistered {
        AnalyticsLibrary.rateCreator(_creator, _rating, appVars);
    }
}
