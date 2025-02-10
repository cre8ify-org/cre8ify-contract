// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library ContentLibrary {
    event FreeContentCreated(
        uint256 indexed id, 
        address indexed creator, 
        string creatorUsername, 
        uint256 indexed timestamp
    );

    event FreeContentDeleted(
        uint256 indexed freeContentID, 
        address indexed creator, 
        string creatorUsername, 
        uint256 indexed timestamp
    );

    function createFreeContent(
        string memory _title,
        string memory _ipfsHash,
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
            creatorImage: _creatorImage
        });

        appVars.freeContents[appVars.freeContentCount] = newContent;
        appVars.freeContentsArray.push(newContent);
        appVars.creatorFreeContents[msg.sender].push(newContent);

        emit FreeContentCreated(appVars.freeContentCount, msg.sender, username, block.timestamp);

        appVars.freeContentCount++;
        appVars.creatorFreeContentCount[msg.sender]++;
    }

    function deleteFreeContent(
        uint256 _id, 
        LayoutLibrary.CCPLayout storage appVars
    ) external {
        AppLibrary.ContentItem storage content = appVars.freeContents[_id];
        require(content.creator == msg.sender, "You are not the creator");

        uint256 creatorContentIndex = content.contentId;
        uint256 globalContentIndex = _id;

        // Swap and remove from creator's content list
        uint256 lastCreatorContentIndex = appVars.creatorFreeContents[msg.sender].length - 1;
        if (creatorContentIndex < lastCreatorContentIndex) {
            AppLibrary.ContentItem storage lastCreatorContent = appVars.creatorFreeContents[msg.sender][lastCreatorContentIndex];
            appVars.creatorFreeContents[msg.sender][creatorContentIndex] = lastCreatorContent;
            appVars.creatorFreeContents[msg.sender][creatorContentIndex].contentId = creatorContentIndex;
        }
        appVars.creatorFreeContents[msg.sender].pop();

        // Swap and remove from global content list
        uint256 lastGlobalContentIndex = appVars.freeContentsArray.length - 1;
        if (globalContentIndex < lastGlobalContentIndex) {
            AppLibrary.ContentItem storage lastGlobalContent = appVars.freeContentsArray[lastGlobalContentIndex];
            appVars.freeContentsArray[globalContentIndex] = lastGlobalContent;
            appVars.freeContentsArray[globalContentIndex].id = globalContentIndex;
            appVars.freeContents[lastGlobalContent.id] = lastGlobalContent;
        }
        appVars.freeContentsArray.pop();

        delete appVars.freeContents[_id];

        appVars.freeContentCount--;
        appVars.creatorFreeContentCount[msg.sender]--;

        emit FreeContentDeleted(_id, msg.sender, content.creatorProfile, block.timestamp);
    }

    function fetchFreeContent(
        LayoutLibrary.CCPLayout storage appVars
    ) external view returns (AppLibrary.ContentItem[] memory) {
        return appVars.freeContentsArray;
    }

    function fetchMyFreeContent(
        address _creator, 
        LayoutLibrary.CCPLayout storage appVars
    ) external view returns (AppLibrary.ContentItem[] memory) {
        return appVars.creatorFreeContents[_creator];
    }

    function fetchFreeContentAnalytics(
        uint256 _id, 
        LayoutLibrary.CCPLayout storage appVars
    ) external view returns (AppLibrary.ContentAnalytics memory) {
        return appVars.analyticsContract.getFreeContentAnalytics(_id);
    }

    function fetchCreatorAnalytics(
        address _creator, 
        LayoutLibrary.CCPLayout storage appVars
    ) external view returns (AppLibrary.CreatorAnalytics memory) {
        return appVars.analyticsContract.getCreatorAnalytics(_creator);
    }
}
