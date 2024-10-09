// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/AnalyticsLibrary.sol";
import "./lib/ContentLibrary.sol";

contract CCP {

    LayoutLibrary.CCPLayout internal appVars;

    constructor(address _authorization, address _analytic, address _subscription) {
        appVars.authorizationContract = IAuthorization(_authorization);
        appVars.analyticsContract = IAnalytics(_analytic);
        appVars.subscriptionContract = ISubscription(_subscription);
    }

    modifier onlyRegistered() {
        require(appVars.authorizationContract.checkRegisteredUsers(msg.sender), "User is not registered");
        _;
    }

    function createFreeContent(
        string memory _title,
        string memory _ipfsHash,
        string memory _contentType,
        string memory username,
        string memory _creatorImage
    ) public onlyRegistered {

        ContentLibrary.createFreeContent(_title, _ipfsHash, _contentType, username, _creatorImage, appVars);

    }

    function createExclusiveContent(
        string memory _title,
        string memory _ipfsHash,
        string memory _contentType,
        string memory username,
        string memory _creatorImage
    ) public onlyRegistered {
        
        ContentLibrary.createExclusiveContent(_title, _ipfsHash, _contentType, username, _creatorImage, appVars);

    }


    function deleteFreeContent(uint256 _id) public onlyRegistered {
        
        ContentLibrary.deleteFreeContent(_id, appVars);

    }

    function deleteExclusiveContent(uint256 _id) public onlyRegistered {
        
        ContentLibrary.deleteExclusiveContent(_id, appVars);

    }

    function fetchFreeContent() public view returns(AppLibrary.ContentItem[] memory){

        return ContentLibrary.fetchFreeContent(appVars);

    }

    function fetchExclusiveContent(address _creator) public returns(AppLibrary.ContentItem[] memory){

        return ContentLibrary.fetchExclusiveContent(_creator, appVars);

    }

    function fetchMyFreeContent(address _creator) public view returns(AppLibrary.ContentItem[] memory){

        return ContentLibrary.fetchMyFreeContent(_creator, appVars);

    }

    function fetchMyExclusiveContent() public returns(AppLibrary.ContentItem[] memory){
        
        return ContentLibrary.fetchMyExclusiveContent(appVars);

    }

    function fetchFollowers(address _creator) public view onlyRegistered returns(AppLibrary.User[] memory){

        return AnalyticsLibrary.getFollowers(_creator, appVars);
        
    }

    function fetchFreeContentAnalytics(uint256 _id) public view onlyRegistered returns(AppLibrary.ContentAnalytics memory){

        return ContentLibrary.fetchFreeContentAnalytics(_id, appVars);

    }

    function fetchExclusiveContentAnalytics(uint256 _id) public view onlyRegistered returns(AppLibrary.ContentAnalytics memory){
        
        return ContentLibrary.fetchExclusiveContentAnalytics(_id, appVars);

    }

    function fetchCreatorAnalytics(address _creator) public view onlyRegistered returns(AppLibrary.CreatorAnalytics memory){
        
        return ContentLibrary.fetchCreatorAnalytics(_creator, appVars);

    }


    function followCreator(address _creator) public onlyRegistered {
        
        AnalyticsLibrary.followCreator(_creator, appVars);

    }

    function unFollowCreator(address _creator) public onlyRegistered {
        
        AnalyticsLibrary.unFollowCreator(_creator, appVars);

    }


    function likeFreeContent(uint256 _id) public onlyRegistered {
        
        AnalyticsLibrary.likeFreeContent(_id, appVars);

    }

    function dislikeFreeContent(uint256 _id) public onlyRegistered {
        
        AnalyticsLibrary.dislikeFreeContent(_id, appVars);

    }

    function likeExclusiveContent(uint256 _id, address _creator) public onlyRegistered {
        
        AnalyticsLibrary.likeExclusiveContent(_id, _creator, appVars);

    }

    function dislikeExclusiveContent(uint256 _id, address _creator) public onlyRegistered {

        AnalyticsLibrary.dislikeExclusiveContent(_id, _creator, appVars);

    }


    function rateFreeContent(uint256 _id, uint _rating) public onlyRegistered {
        
        AnalyticsLibrary.rateFreeContent(_id, _rating, appVars);

    }

    function rateExclusiveContent(uint256 _id, address _creator, uint256 _rating) public onlyRegistered {
        
        AnalyticsLibrary.rateExclusiveContent(_id, _creator, _rating, appVars);

    }

    function rateCreator(address _creator, uint _rating) public onlyRegistered {
        
        AnalyticsLibrary.rateCreator(_creator, _rating, appVars);

    }

}
