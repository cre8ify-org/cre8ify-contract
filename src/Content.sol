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
        string creatorProfile; // Changed from address to string
        string ipfsHash;
        address creator;
        bool isDeleted;
        bool isMonetized;
        uint256 views;
        uint256 likes;
        uint256 rating;
        uint256 shares; // Added shares
        string contentType; // Added content type
    }

    mapping(uint256 => ContentItem) public contents;
    mapping(address => ContentItem[]) private userContentTracker;

    //Reward system variables
    uint256 public tokenRewardPerView = 1; // Reward per view in tokens
    uint256 public tokenRewardPerLike = 5; // Reward per like in tokens
    uint256 public tokenRewardPerShare = 10; // Reward per share in tokens
    uint256 public payoutThreshold = 100; // Threshold for payout in tokens

    mapping(address => uint256) public userRewards; // Mapping of user addresses to their accrued rewards
    uint256 public cooldownDuration = 1 days; // Cooldown duration in seconds
    mapping(address => uint256) public lastRewardClaim; // Mapping of user addresses to their last reward claim time

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
        ); // Remove creatorAddress and profileImage

        contentCount++;
        ContentItem memory newContent = ContentItem({
            title: _title,
            id: contentCount,
            dateCreated: block.timestamp,
            creator: msg.sender,
            creatorProfile: username, // Changed from msg.sender to username
            ipfsHash: _ipfsHash,
            isDeleted: false,
            isMonetized: false,
            views: 0,
            likes: 0,
            rating: 0,
            shares: 0,
            contentType: _contentType // Added content type
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

    /**
     * tokenRewardPerView, tokenRewardPerLike, and tokenRewardPerShare variables
        to define the reward amount per view, like, and share.
     * userRewards mapping to keep track of the accrued rewards for each user.
     * calculateReward function to calculate the total reward for a content
        item based on its views, likes, and shares.
     * payoutReward function that allows users to withdraw their accrued 
        rewards once they reach the payoutThreshold.
    * Updates to the viewContent, likeContent, and shareContent functions 
        to increment the user's rewards when their content is interacted with.
     */

    // Calculate reward function
    function calculateReward(uint256 _id) public view returns (uint256) {
        ContentItem memory content = contents[_id];
        uint256 viewsReward = content.views * tokenRewardPerView;
        uint256 likesReward = content.likes * tokenRewardPerLike;
        uint256 sharesReward = content.shares * tokenRewardPerShare;
        return viewsReward + likesReward + sharesReward;
    }

    /**
     * A cooldownDuration variable to define the cooldown period in seconds.
     * A lastRewardClaim mapping to keep track of the last time each user claimed 
        their rewards.
     * A check in the payoutReward function to ensure the cooldown period has passed 
        before allowing users to claim their rewards.
     * An update to the lastRewardClaim mapping in the payoutReward function to 
        record the current time when rewards are claimed.
     */

    // Payout/reward distribution function with cooldown
    function payoutReward() public {
        uint256 reward = userRewards[msg.sender];
        require(reward >= payoutThreshold, "Insufficient rewards for payout");
        require(
            block.timestamp - lastRewardClaim[msg.sender] >= cooldownDuration,
            "Cooldown period has not passed"
        );
        payable(msg.sender).transfer(reward);
        userRewards[msg.sender] = 0;
        lastRewardClaim[msg.sender] = block.timestamp;
    }

    // Payout/reward distribution function
    // function payoutReward() public {
    //     uint256 reward = userRewards[msg.sender];
    //     require(reward >= payoutThreshold, "Insufficient rewards for payout");
    //     payable(msg.sender).transfer(reward);
    //     userRewards[msg.sender] = 0;
    // }

    function withdrawReward(uint256 _id) public {
        uint256 reward = calculateReward(_id);
        payable(contents[_id].creator).transfer(reward);
    }

    // Function to get user's content
    function getUserContents(
        address _user
    ) public view returns (ContentItem[] memory) {
        return userContentTracker[_user];
    }

    // Function to fetch 20 contents
    function fetchContents(
        uint256 _lastContentId,
        uint256[] memory _tracker
    ) public view returns (uint256[] memory, ContentItem[] memory) {
        uint256[] memory ids = new uint256[](20);
        ContentItem[] memory returnedContents = new ContentItem[](20);
        uint256[] memory newTracker = new uint256[](20);

        uint256 newContentsCount = 0;
        uint256 randomContentsCount = 0;

        // Fetch newest 10 contents
        for (
            uint256 i = contentCount;
            i > _lastContentId && newContentsCount < 10;
            i--
        ) {
            ids[newContentsCount] = contents[i].id;
            returnedContents[newContentsCount] = contents[i];
            newTracker[newContentsCount] = i;
            newContentsCount++;
        }

        // Fetch 10 pseudo-random contents
        while (randomContentsCount < 10) {
            uint256 randomId = (uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        msg.sender,
                        randomContentsCount
                    )
                )
            ) % contentCount) + 1;

            bool contentShown = false;
            for (uint256 j = 0; j < _tracker.length; j++) {
                if (_tracker[j] == randomId) {
                    contentShown = true;
                    break;
                }
            }

            if (!contentShown && randomId != 0) {
                ids[newContentsCount + randomContentsCount] = contents[randomId]
                    .id;
                returnedContents[
                    newContentsCount + randomContentsCount
                ] = contents[randomId];
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
