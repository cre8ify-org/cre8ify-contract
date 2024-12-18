// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library ContentLibrary{
    event FreeContentCreated(uint256 indexed id, address indexed creator, string creatorUsername, uint256  indexed timestamp);
    // event ExclusiveContentCreated(uint256 indexed id, address indexed creator, string creatorUsername, uint256  indexed timestamp);

    event FreeContentDeleted(uint256 indexed freeContentID, address indexed creator, string creatorUsername, uint256  indexed timestamp);
    // event ExclusiveContentDeleted(uint256 indexed exclusiveContentID, address indexed creator, string creatorUsername, uint256  indexed timestamp);

    function createFreeContent(
        string memory _title,
        string memory _ipfsHash,
        string memory _contentType,
        string memory username,
        string memory _creatorImage,
        LayoutLibrary.CCPLayout storage appVars

    ) external {
        AppLibrary.ContentItem memory newContent = AppLibrary.ContentItem({
            title: _title,
            id: appVars.freeContentCount,
            contentId: appVars.creatorFreeContentCount[msg.sender],
            dateCreated: block.timestamp,
            creator: msg.sender,
            creatorProfile: username, 
            ipfsHash: _ipfsHash,
            views: 0,
            likes: 0,
            dislikes: 0,
            shares: 0,
            rating: 0,
            contentType: _contentType,
            creatorImage: _creatorImage 
        });

        appVars.freeContents[appVars.freeContentCount] = newContent;

        appVars.freeContentsArray.push(newContent);

        appVars.creatorFreeContents[msg.sender].push(newContent);

        emit FreeContentCreated(appVars.freeContentCount, msg.sender, username, block.timestamp);

        appVars.freeContentCount++;
        
        appVars.creatorFreeContentCount[msg.sender]++;
    }

    // function createExclusiveContent(
    //     string memory _title,
    //     string memory _ipfsHash,
    //     string memory _contentType,
    //     string memory username,
    //     string memory _creatorImage,
    //     LayoutLibrary.CCPLayout storage appVars
    // ) external {
    //     AppLibrary.ContentItem memory newContent = AppLibrary.ContentItem({
    //         title: _title,
    //         id: appVars.creatorExclusiveContentCount[msg.sender],
    //         contentId: appVars.creatorExclusiveContentCount[msg.sender],
    //         dateCreated: block.timestamp,
    //         creator: msg.sender,
    //         creatorProfile: username, 
    //         ipfsHash: _ipfsHash,
    //         views: 0,
    //         likes: 0,
    //         dislikes: 0,
    //         shares: 0,
    //         rating: 0,
    //         contentType: _contentType,
    //         creatorImage: _creatorImage 
    //     });

    //     appVars.exclusiveContents[msg.sender][appVars.creatorExclusiveContentCount[msg.sender]] = newContent;

    //     appVars.creatorExclusiveContents[msg.sender].push(newContent);

    //     emit ExclusiveContentCreated(appVars.creatorExclusiveContentCount[msg.sender], msg.sender, username, block.timestamp);

    //     appVars.creatorExclusiveContentCount[msg.sender]++;
    // }


    function deleteFreeContent(uint256 _id, LayoutLibrary.CCPLayout storage appVars) external  {
        AppLibrary.ContentItem storage content = appVars.freeContents[_id];
        require(
            content.creator == msg.sender,
            "You are not the creator"
        );

        if (_id < appVars.freeContentsArray.length) {
            
            appVars.creatorFreeContents[msg.sender][content.contentId] = appVars.creatorFreeContents[msg.sender][appVars.creatorFreeContents[msg.sender].length - 1];
            
            appVars.creatorFreeContents[msg.sender][content.contentId].id = content.id;
            
            appVars.creatorFreeContents[msg.sender][content.contentId].contentId = content.contentId;
            
            appVars.freeContentsArray[_id] = appVars.freeContentsArray[appVars.freeContentsArray.length - 1];
            
            appVars.freeContentsArray[_id].id = content.id;
            
            appVars.freeContentsArray[_id].contentId = content.contentId;

            appVars.freeContents[_id] = appVars.freeContentsArray[_id];
            
            appVars.freeContentsArray.pop();
            
            appVars.creatorFreeContents[msg.sender].pop;

            appVars.freeContentCount--;
            
            appVars.creatorFreeContentCount[msg.sender]--;
        }

        emit FreeContentDeleted(_id, msg.sender, content.creatorProfile, block.timestamp);
    }

    // function deleteExclusiveContent(uint256 _id, LayoutLibrary.CCPLayout storage appVars) external {
        
    //     AppLibrary.ContentItem storage content = appVars.exclusiveContents[msg.sender][_id];

    //     require(
    //         content.creator == msg.sender,
    //         "You are not the creator"
    //     );

    //     if (_id < appVars.creatorExclusiveContents[msg.sender].length) {

    //         appVars.creatorExclusiveContents[msg.sender][_id] = appVars.creatorExclusiveContents[msg.sender][appVars.creatorExclusiveContents[msg.sender].length - 1];
            
    //         appVars.creatorExclusiveContents[msg.sender][_id].id = content.id;
            
    //         appVars.creatorExclusiveContents[msg.sender][_id].contentId = content.contentId;

    //         appVars.exclusiveContents[msg.sender][_id] = appVars.creatorExclusiveContents[msg.sender][_id];
            
    //         appVars.creatorExclusiveContents[msg.sender].pop();

    //         appVars.creatorExclusiveContentCount[msg.sender]--;
    //     }

    //     emit ExclusiveContentDeleted(_id, msg.sender, content.creatorProfile, block.timestamp);
    // }

    function fetchFreeContent(LayoutLibrary.CCPLayout storage appVars) external view returns(AppLibrary.ContentItem[] memory){
        
        return appVars.freeContentsArray;

    }

    // function fetchExclusiveContent(address _creator, LayoutLibrary.CCPLayout storage appVars) external returns(AppLibrary.ContentItem[] memory){
        
    //     require(appVars.subscriptionContract.checkSubscribtionToCreatorStatus(_creator, msg.sender), "You are not subscribed");

    //     appVars.fetchExclusiveContentTimestamp[msg.sender] = block.timestamp;

    //     return appVars.creatorExclusiveContents[_creator];
    // }

    function fetchMyFreeContent(address _creator, LayoutLibrary.CCPLayout storage appVars) external view returns(AppLibrary.ContentItem[] memory){
        
        return appVars.creatorFreeContents[_creator];

    }

    // function fetchMyExclusiveContent(LayoutLibrary.CCPLayout storage appVars) external returns(AppLibrary.ContentItem[] memory){
        
    //     appVars.fetchExclusiveContentTimestamp[msg.sender] = block.timestamp;

    //     return appVars.creatorExclusiveContents[msg.sender];

    // }

    function fetchFreeContentAnalytics(uint256 _id, LayoutLibrary.CCPLayout storage appVars) external view returns(AppLibrary.ContentAnalytics memory){

        return appVars.analyticsContract.getFreeContentAnalytics(_id);

    }

    // function fetchExclusiveContentAnalytics(uint256 _id, LayoutLibrary.CCPLayout storage appVars) external view  returns(AppLibrary.ContentAnalytics memory){
        
    //     return appVars.analyticsContract.getExclusiveContentAnalytics(_id);

    // }

    function fetchCreatorAnalytics(address _creator, LayoutLibrary.CCPLayout storage appVars) external view returns(AppLibrary.CreatorAnalytics memory){
        
        return appVars.analyticsContract.getCreatorAnalytics(_creator);

    }
}