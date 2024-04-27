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
        string creatorProfile;
        string ipfsHash;
        address creator;
        bool isDeleted;
        bool isMonetized;
        uint256 views;
        uint256 likes;
        uint256 shares;
        string contentType;
    }

    mapping(uint256 => ContentItem) public contents;
    mapping(address => ContentItem[]) private userContentTracker;

    //Reward system variables
    uint256 public tokenRewardPerView = 1; 
    uint256 public tokenRewardPerLike = 5; 
    uint256 public tokenRewardPerShare = 10; 
    uint256 public payoutThreshold = 100; 

    mapping(address => uint256) public userRewards; 
    uint256 public cooldownDuration = 1 days; 
    mapping(address => uint256) public lastRewardClaim; 

    ContentItem[] contentsArray;

    uint256 public contentCount;

    Analytics public analyticsContract;
    Authorization public authorizationContract;

    constructor(
        address _analyticsContract,
        address _authorizationContract
    ) Ownable(msg.sender) {
        analyticsContract = Analytics(_analyticsContract);
        authorizationContract = Authorization(_authorizationContract);
    }

    event ContentCreated(uint256 id, string title, string creatorProfile);
    event ContentMonetized(uint256 id, string creatorProfile);
    event ContentViewed(uint256 id);
    event ContentLiked(uint256 id);
    event ContentShared(uint256 id, address indexed sharer);
    event ContentDeleted(uint256 id);
    event ContentTransferred(uint256 id, address indexed newOwner);

    // Create content
    function createContent(
        string memory _title,
        string memory _ipfsHash,
        string memory _contentType
    ) public {
        (string memory username, , ) = authorizationContract.getUserDetails(
            msg.sender
        ); 

        contentCount++;
        ContentItem memory newContent = ContentItem({
            title: _title,
            id: contentCount,
            dateCreated: block.timestamp,
            creator: msg.sender,
            creatorProfile: username, 
            ipfsHash: _ipfsHash,
            isDeleted: false,
            isMonetized: false,
            views: 0,
            likes: 0,
            shares: 0,
            contentType: _contentType 
        });

        contents[contentCount] = newContent;

        contentsArray.push(newContent);

        userContentTracker[msg.sender].push(newContent);

        emit ContentCreated(contentCount, _title, username);
    }

    // Monetize content
    function monetizeContent(uint256 _id) public {
        (string memory username, , ) = authorizationContract.getUserDetails(
            msg.sender
        );
        string memory creatorProfile = contents[_id].creatorProfile;
        require(
            keccak256(abi.encodePacked(creatorProfile)) ==
                keccak256(abi.encodePacked(username)),
            "You are not the creator"
        );
        require(!contents[_id].isMonetized, "Content is already monetized");
        contents[_id].isMonetized = true;
        emit ContentMonetized(_id, username);
    }

    // View content
    function viewContent(uint256 _id) public {
        contents[_id].views++;
        emit ContentViewed(_id);
        analyticsContract.trackView(_id);
        userRewards[contents[_id].creator] += tokenRewardPerView;
    }

    // Like content
    function likeContent(uint256 _id) public {
        contents[_id].likes++;
        emit ContentLiked(_id);
        analyticsContract.trackLike(_id);
        userRewards[contents[_id].creator] += tokenRewardPerLike;
    }

    // Share content
    function shareContent(uint256 _id) public {
        emit ContentShared(_id, msg.sender);
        userRewards[contents[_id].creator] += tokenRewardPerShare;
    }

    // Transfer content ownership (only owner can transfer)
    function transferContent(uint256 _id, address _newOwner) public onlyOwner {
        (string memory newUsername, , ) = authorizationContract.getUserDetails(
            _newOwner
        );
        contents[_id].creatorProfile = newUsername;
        emit ContentTransferred(_id, _newOwner);
    }

    // Delete content (only owner can delete)
    function deleteContent(uint256 _id) public onlyOwner {
        contents[_id].isDeleted = true;
        emit ContentDeleted(_id);
    }

 // Calculate reward function
function calculateReward(uint256 _id) public view returns (uint256) {
    ContentItem memory content = contents[_id];
    uint256 viewsReward = content.views * tokenRewardPerView;
    uint256 likesReward = content.likes * tokenRewardPerLike;
    uint256 sharesReward = content.shares * tokenRewardPerShare;
    return viewsReward + likesReward + sharesReward;
}}