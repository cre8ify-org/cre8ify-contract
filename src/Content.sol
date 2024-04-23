// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Authorization.sol";
import "./Analytics.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Content is Ownable {
    struct ContentItem {
        string title;
        uint256 id;
        uint256 dateCreated;
        address creator;
        string ipfsHash;
        bool isDeleted;
        bool isMonetized;
        uint256 views;
        uint256 likes;
        uint256 rating;
    }

    mapping(uint256 => ContentItem) public contents;
    mapping(address => ContentItem[]) private userContentTracker;

    ContentItem[] contentsArray;

    uint256 public contentCount;

    Analytics public analyticsContract;
    Authorization public authorizationContract;

    constructor(address _analyticsContract, address _authorizationContract) Ownable(msg.sender) {
        analyticsContract = Analytics(_analyticsContract);
        authorizationContract = Authorization(_authorizationContract);
    }

    event ContentCreated(uint256 id, string title, address indexed creator);
    event ContentMonetized(uint256 id, address indexed creator);
    event ContentViewed(uint256 id);
    event ContentLiked(uint256 id);
    event ContentShared(uint256 id, address indexed sharer);
    event ContentDeleted(uint256 id);
    event ContentTransferred(uint256 id, address indexed newOwner);

    // Create content
    function createContent(string memory _title, string memory _ipfsHash) public {
        (string memory username, address creatorAddress, string memory profileImage) = authorizationContract.getUserDetails(msg.sender);

        contentCount++;
        ContentItem memory newContent = ContentItem({
            title: _title,
            id: contentCount,
            dateCreated: block.timestamp,
            creator: creatorAddress,
            ipfsHash: _ipfsHash,
            isDeleted: false,
            isMonetized: false,
            views: 0,
            likes: 0,
            rating: 0
        });

        contents[contentCount] = newContent;

        contentsArray.push(newContent);

        userContentTracker[msg.sender].push(newContent);

        emit ContentCreated(contentCount, _title, creatorAddress);
    }

    // Monetize content
    function monetizeContent(uint256 _id) public {
        require(contents[_id].creator == msg.sender, "You are not the creator");
        require(!contents[_id].isMonetized, "Content is already monetized");
        
        contents[_id].isMonetized = true;
        emit ContentMonetized(_id, msg.sender);
    }

    // View content
    function viewContent(uint256 _id) public {
        contents[_id].views++;
        emit ContentViewed(_id);
        analyticsContract.trackView(_id);
    }

    // Like content
    function likeContent(uint256 _id) public {
        contents[_id].likes++;
        emit ContentLiked(_id);
        analyticsContract.trackLike(_id);
    }

    // Share content
    function shareContent(uint256 _id) public {
        emit ContentShared(_id, msg.sender);
    }

    // Transfer content ownership (only owner can transfer)
    function transferContent(uint256 _id, address _newOwner) public onlyOwner {
        contents[_id].creator = _newOwner;
        emit ContentTransferred(_id, _newOwner);
    }

    // Delete content (only owner can delete)
    function deleteContent(uint256 _id) public onlyOwner {
        contents[_id].isDeleted = true;
        emit ContentDeleted(_id);
    }

    // Reward calculation and withdrawal
    function calculateReward(uint256 _id) public view returns (uint256) {
        return contents[_id].views + contents[_id].likes + contents[_id].rating;
    }

    function withdrawReward(uint256 _id) public {
        uint256 reward = calculateReward(_id);
        payable(contents[_id].creator).transfer(reward);
    }

    // Function to get user's content
    function getUserContents(address _user) public view returns (ContentItem[] memory) {
        return userContentTracker[_user];
    }

    // Function to fetch 20 contents
    function fetchContents(uint256 _lastContentId, uint256[] memory _tracker )
        public
        view
        returns (uint256[] memory, ContentItem[] memory)
    {
        uint256[] memory ids = new uint256[](20);
        ContentItem[] memory returnedContents = new ContentItem[](20);
        uint256[] memory newTracker = new uint256[](20);

        uint256 newContentsCount = 0;
        uint256 randomContentsCount = 0;

        // Fetch newest 10 contents
        for (uint256 i = contentCount; i > _lastContentId && newContentsCount < 10; i--) {
            ids[newContentsCount] = contents[i].id;
            returnedContents[newContentsCount] = contents[i];
            newTracker[newContentsCount] = i;
            newContentsCount++;
        }

        // Fetch 10 pseudo-random contents
        while (randomContentsCount < 10) {
            uint256 randomId = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randomContentsCount))) % contentCount) + 1;
            
            bool contentShown = false;
            for (uint256 j = 0; j < _tracker.length; j++) {
                if (_tracker[j] == randomId) {
                    contentShown = true;
                    break;
                }
            }

            if (!contentShown && randomId != 0) {
                ids[newContentsCount + randomContentsCount] = contents[randomId].id;
                returnedContents[newContentsCount + randomContentsCount] = contents[randomId];
                newTracker[newContentsCount + randomContentsCount] = randomId;
                randomContentsCount++;
            }
        }

        return (newTracker, returnedContents);
    }

    function isContentMonetized(uint256 contentId) public view returns (bool) {
    return contents[contentId].isMonetized;
}
    
}
