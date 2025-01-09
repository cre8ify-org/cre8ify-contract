// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./LayoutLibrary.sol";

library AppLibrary {
    struct User {
        string username;
        address walletAddress;
        string profileImage;
        uint256 totalTipsReceived; // Total tips received by the user
        string[] badges; // Badges earned by the user
    }

    struct ContentItem {
        string title;
        uint256 id;
        uint256 contentId;
        uint256 dateCreated;
        address creator;
        string creatorProfile;
        string ipfsHash;
        uint256 views;
        uint256 likes;
        uint256 dislikes;
        uint256 shares;
        uint256 rating;
        string contentType;
        string creatorImage;
    }

    function searchContentByTitle(
        string memory _title,
        LayoutLibrary.ContentDiscoveryLayout storage discoveryVars
    ) internal view returns (ContentItem[] memory) {
        uint256 resultCount;
        for (uint256 i = 0; i < discoveryVars.freeContentsArray.length; i++) {
            if (
                keccak256(bytes(discoveryVars.freeContentsArray[i].title)) ==
                keccak256(bytes(_title))
            ) {
                resultCount++;
            }
        }

        ContentItem[] memory results = new ContentItem[](resultCount);
        uint256 index = 0;
        for (uint256 i = 0; i < discoveryVars.freeContentsArray.length; i++) {
            if (
                keccak256(bytes(discoveryVars.freeContentsArray[i].title)) ==
                keccak256(bytes(_title))
            ) {
                results[index] = discoveryVars.freeContentsArray[i];
                index++;
            }
        }
        return results;
    }

    function searchCreatorsByUsername(
        string memory _username,
        LayoutLibrary.ContentDiscoveryLayout storage discoveryVars
    ) internal view returns (User memory) {
        address walletAddress = discoveryVars
            .authorizationContract
            .getUserAddress(_username);
        return
            discoveryVars.authorizationContract.getUserDetails(walletAddress);
    }

    function getTrendingFreeContent(
        LayoutLibrary.ContentDiscoveryLayout storage discoveryVars
    ) internal view returns (ContentItem[] memory) {
        uint256 topCount = discoveryVars.trendingCount;
        ContentItem[] memory trending = new ContentItem[](topCount);

        for (uint256 i = 0; i < topCount; i++) {
            trending[i] = discoveryVars.freeContentsArray[i];
        }

        return trending;
    }

    function getTrendingCreators(
        LayoutLibrary.ContentDiscoveryLayout storage discoveryVars
    ) internal view returns (User[] memory) {
        uint256 topCount = discoveryVars.trendingCount;
        User[] memory trending = new User[](topCount);

        for (uint256 i = 0; i < topCount; i++) {
            trending[i] = discoveryVars.creatorsArray[i];
        }

        return trending;
    }

    function getRecommendedFreeContent(
        address _user,
        LayoutLibrary.ContentDiscoveryLayout storage discoveryVars
    ) internal view returns (ContentItem[] memory) {
        uint256 recommendationsCount = discoveryVars.recommendationsCount;
        ContentItem[] memory recommendations = new ContentItem[](
            recommendationsCount
        );

        for (uint256 i = 0; i < recommendationsCount; i++) {
            recommendations[i] = discoveryVars.recommendedContents[_user][i];
        }

        return recommendations;
    }
}
