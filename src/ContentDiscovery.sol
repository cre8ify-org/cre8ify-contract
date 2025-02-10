// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/LayoutLibrary.sol";
import "./lib/AppLibrary.sol";

contract ContentDiscovery {
    LayoutLibrary.ContentDiscoveryLayout internal discoveryVars;

    constructor(address _ccpContract, address _authorization) {
        discoveryVars.ccpContract = _ccpContract;
        discoveryVars.authorizationContract = IAuthorization(_authorization);
    }

    modifier onlyRegistered() {
        require(
            discoveryVars.authorizationContract.checkRegisteredUsers(
                msg.sender
            ),
            "User is not registered"
        );
        _;
    }

    function searchFreeContentByTitle(
        string memory _title
    ) public view onlyRegistered returns (AppLibrary.ContentItem[] memory) {
        return AppLibrary.searchContentByTitle(_title, discoveryVars);
    }

    function searchCreatorsByUsername(
        string memory _username
    ) public view onlyRegistered returns (AppLibrary.User memory) {
        return AppLibrary.searchCreatorsByUsername(_username, discoveryVars);
    }

    function fetchTrendingFreeContent()
        public
        view
        onlyRegistered
        returns (AppLibrary.ContentItem[] memory)
    {
        return AppLibrary.getTrendingFreeContent(discoveryVars);
    }

    function fetchTrendingCreators()
        public
        view
        onlyRegistered
        returns (AppLibrary.User[] memory)
    {
        return AppLibrary.getTrendingCreators(discoveryVars);
    }

    function fetchRecommendedFreeContent(
        address _user
    ) public view onlyRegistered returns (AppLibrary.ContentItem[] memory) {
        return AppLibrary.getRecommendedFreeContent(_user, discoveryVars);
    }
}
