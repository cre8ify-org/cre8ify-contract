// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Authorization.sol";
import "./Analytics.sol";
import "./Subscription.sol";

contract CCP {
    // Maximum score a creator can achieve
    uint256 CREATOR_SCORE_CAP = 400 ether;

    // Minimum score required to be in the top 20
    uint256 MIN_CREATOR_SCORE = 40 ether;

    uint256 CONTENT_SCORE_CAP = 100 ether;

    // Minimum score required to be in the top 20
    uint256 MIN_CONTENT_SCORE = 50 ether;

    uint256 constant weightRating = 3;
    uint256 constant weightLike = 2;
    uint256 constant weightDislike = 3; 
    uint256 constant weightView = 1;
    uint256 constant weightShare = 1;

    uint256 constant tokenRewardPerRating = 1;
    uint256 constant tokenRewardPerView = 1; 
    uint256 constant tokenRewardPerLike = 5; 
    uint256 constant tokenRewardPerShare = 10;

    uint256 payoutThreshold = 100; 

    uint256 constant MIN_DECAY_FACTOR = 1 ether; 
    uint256 constant INITIAL_DECAY_FACTOR = 5 ether;

    uint256 TIMESTAMP_FACTOR = 345600;

    Authorization public authorizationContract;
    Analytics public analyticsContract;
    Subscription public subscriptionContract;


    struct User {
        string username;
        address walletAddress;
        string profileImage; // IPFS hash or URL for profile image
    }

    struct vars {
        uint256[] top20CreatorScores;
        uint256[] top20ContentScores;
        User[] top20Creators;
        ContentItem[] top20Contents;
        mapping(address => uint256) creatorScores;
        mapping(uint256 => uint256) contentScores;
        uint256 contentCount;
        mapping(address => uint256) creatorContentCount;
        ContentItem[] contentsArray;
        mapping(address => ContentItem[]) creatorContents;
        
        mapping(uint256 => ContentItem) contents;
        mapping(uint256 => uint256) contentDemerits;
        mapping(uint256 => uint256) contentDemeritsTimestamp;
        mapping(address => uint256) creatorDemerits;
        mapping(address => uint256) creatorDemeritsTimestamp;
        mapping(uint256 => mapping(address => uint256)) userContentRatings;
        mapping(uint256 => uint256) contentRatingSum;
        mapping(uint256 => uint256) contentRatingCount;
        mapping(address => ContentItem[]) userContentTracker;
        mapping(uint256 => mapping(address => bool)) contentLikeTracker;
        mapping(uint256 => mapping(address => bool)) contentDislikeTracker;
        mapping(address => uint256) userRewardsAccumulated;


        mapping(address => uint256) creatorRating;
        mapping(address => uint256) creatorRatingSum;
        mapping(address => uint256) creatorRatingCount;
        mapping(address => mapping(address => uint256)) userCreatorRatings;
    }

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
        uint256 dislikes;
        uint256 shares;
        uint256 rating;
        string contentType;
    }
    
    vars appVars;

    constructor(address _authorization, address _analytic, address _subscription) {
        authorizationContract = Authorization(_authorization);
        analyticsContract = Analytics(_analytic);
        subscriptionContract = Subscription(_subscription);
    }

    event ContentCreated(uint256 indexed id, string indexed creatorProfile, uint256  indexed timestamp);
    event ContentMonetized(uint256 id, address creatorProfile);
    event ContentDemonetized(uint256 id, address creatorProfile);
    event ContentLiked(uint256 indexed id, address indexed creator, uint256  indexed timestamp);
    event ContentDisliked(uint256 indexed id, address indexed creator, uint256 indexed timestamp);
    event ContentViewed(uint256 indexed id, address indexed creator, uint256 indexed timestamp);
    event ContentShared(uint256 indexed id, address indexed creator, uint256 indexed timestamp);
    event ContentRated(uint256 indexed id, address indexed creator, uint256 indexed timestamp, uint256 rating);
    event CreatorRated(address indexed creator, uint256 indexed timestamp, uint256 rating);

    modifier onlyRegistered() {
        require(authorizationContract.registeredUsers(msg.sender), "User is not registered");
        _;
    }

    modifier onlySubscriber() {
        require(subscriptionContract.isUserSubscribed(msg.sender), "User is not subscribed or subscription expired");
        _;
    }

    // copied function start------------------------
    function createContent(
        string memory _title,
        string memory _ipfsHash,
        string memory _contentType,
        string memory username
    ) public onlyRegistered {
        ContentItem memory newContent = ContentItem({
            title: _title,
            id: appVars.contentCount,
            dateCreated: block.timestamp,
            creator: msg.sender,
            creatorProfile: username, 
            ipfsHash: _ipfsHash,
            isDeleted: false,
            isMonetized: false,
            views: 0,
            likes: 0,
            dislikes: 0,
            shares: 0,
            rating: 0,
            contentType: _contentType 
        });

        appVars.contents[appVars.contentCount] = newContent;

        appVars.contentsArray.push(newContent);

        appVars.userContentTracker[msg.sender].push(newContent);

        appVars.creatorContents[msg.sender].push(newContent);

        appVars.contentCount++;

        appVars.creatorContentCount[msg.sender]++;

        emit ContentCreated(appVars.contentCount, username, block.timestamp);
    }

    function monetizeContent(uint256 _id) public onlyRegistered onlySubscriber {
        address creatorProfile = appVars.contents[_id].creator;
        require(
            creatorProfile == msg.sender,
            "You are not the creator"
        );
        require(!appVars.contents[_id].isMonetized, "Content is already monetized");
        appVars.contents[_id].isMonetized = true;
        appVars.contentsArray[_id].isMonetized = true;
        emit ContentMonetized(_id, msg.sender);
    }

    function demonetizeContent(uint256 _id) public onlyRegistered {
        address creatorProfile = appVars.contents[_id].creator;
        require(
            creatorProfile == msg.sender,
            "You are not the creator"
        );
        require(appVars.contents[_id].isMonetized, "Content is not monetized");
        appVars.contents[_id].isMonetized = false;
        emit ContentDemonetized(_id, msg.sender);
    }

    function viewContent(uint256 _id) public onlyRegistered {
        appVars.contentsArray[_id].views++;
        appVars.contents[_id].views++;
        
        ContentItem memory content = appVars.contents[_id];
        updateScores(content);

        emit ContentViewed(_id, content.creator, block.timestamp);
        analyticsContract.trackView(_id);

        if (content.isMonetized){
            appVars.userRewardsAccumulated[content.creator] += tokenRewardPerLike;
        }
    }

    function likeContent(uint256 _id) public onlyRegistered {
        if (appVars.contentLikeTracker[_id][msg.sender]){
            appVars.contentsArray[_id].dislikes--;
            appVars.contents[_id].dislikes--;
            appVars.contentDislikeTracker[_id][msg.sender] = false;
        }

        if(!appVars.contentLikeTracker[_id][msg.sender]){
            appVars.contentLikeTracker[_id][msg.sender] = true;
            appVars.contentsArray[_id].likes++;
            appVars.contents[_id].likes++;

            ContentItem memory content = appVars.contents[_id];
            updateScores(content);

            emit ContentLiked(_id, content.creator, block.timestamp);
            analyticsContract.trackLike(_id);

            if (content.isMonetized){
                appVars.userRewardsAccumulated[content.creator] += tokenRewardPerLike;
            }
        }
    }

    function dislikeContent(uint256 _id) public onlyRegistered {
        ContentItem memory content = appVars.contents[_id];

        if (appVars.contentLikeTracker[_id][msg.sender]){
            appVars.contentsArray[_id].likes--;
            appVars.contents[_id].likes--;
            appVars.contentLikeTracker[_id][msg.sender] = false;

            if (content.isMonetized){
                appVars.userRewardsAccumulated[content.creator] -= tokenRewardPerLike;
            }
        }

        if(!appVars.contentDislikeTracker[_id][msg.sender]){
            appVars.contentDislikeTracker[_id][msg.sender] = true;
            appVars.contentsArray[_id].dislikes++;
            appVars.contents[_id].dislikes++;
            updateScores(content);

            emit ContentDisliked(_id, content.creator, block.timestamp);
            analyticsContract.trackDislike(_id);
        }
    }

    function shareContent(uint256 _id) public onlyRegistered {
        appVars.contentsArray[_id].shares++;
        appVars.contents[_id].shares++;

        ContentItem memory content = appVars.contents[_id];
        updateScores(content);

        emit ContentShared(_id, content.creator, block.timestamp);
        analyticsContract.trackShare(_id);

        if (content.isMonetized){
            appVars.userRewardsAccumulated[content.creator] += tokenRewardPerShare;
        }
    }

    function rateContent(uint256 _id, uint _rating) public onlyRegistered {
        require(_rating >= 1 && _rating <= 5, "Invalid rating");
        uint256 previousRating = appVars.userContentRatings[_id][msg.sender];

        if (!(previousRating < 1)) {
            appVars.contentRatingSum[_id] -= previousRating;
            appVars.contentRatingCount[_id] -= 1; 
        }

        appVars.userContentRatings[_id][msg.sender] = _rating;

        appVars.contentRatingSum[_id] += _rating;
        appVars.contentRatingCount[_id] += 1;

        uint256 averageRating = (appVars.contentRatingSum[_id] / appVars.contentRatingCount[_id]) * 1 ether;

        appVars.contentsArray[_id].rating = averageRating;
        appVars.contents[_id].rating = averageRating;

        ContentItem memory content = appVars.contents[_id];
        updateScores(content);

        emit ContentRated(_id, content.creator, block.timestamp, _rating);
        analyticsContract.trackRating(_id, averageRating);
    }

    function rateCreator(address creator, uint _rating) public onlyRegistered {
        require(_rating >= 1 && _rating <= 5, "Invalid rating");
        uint256 previousRating = appVars.userCreatorRatings[creator][msg.sender];

        if (!(previousRating < 1)) {
            appVars.creatorRatingSum[creator] -= previousRating;
            appVars.creatorRatingCount[creator] -= 1; 
        }

        appVars.userCreatorRatings[creator][msg.sender] = _rating;

        appVars.creatorRatingSum[creator] += _rating;
        appVars.creatorRatingCount[creator] += 1;

        uint256 averageRating = (appVars.creatorRatingSum[creator] / appVars.creatorRatingCount[creator]) * 1 ether;

        appVars.creatorRating[creator] = averageRating;

        emit CreatorRated(creator, block.timestamp, _rating);
    }

    function getContent(uint256 _id) public view returns(ContentItem memory){
        return appVars.contentsArray[_id];
    }

    // // Function to update a creator's score
    function updateScores(ContentItem memory content) private {
        uint256 newScore = calculateWeightedScore(content.rating, content.likes, content.dislikes, content.views, content.shares);

        // Cap the new score
        uint256 creatorScore = newScore - ((appVars.creatorDemerits[content.creator] * calculateDecayFactor(content.dateCreated)  / 1 ether ));
        uint256 trendingScore = ((newScore * calculateDecayFactor(content.dateCreated)) / 1 ether) - appVars.contentDemerits[content.id];

        appVars.creatorScores[content.creator] = creatorScore;
        appVars.contentScores[content.id] = trendingScore;
    }

    // Function to update the top 20 rankings
    function updateTopContent(uint256 content, uint256 newScore) private {
        // Check if the new score qualifies for the top 20
        if (newScore <= MIN_CONTENT_SCORE) {
            return;
        }

        // Find the insertion position for the new creator (start from the back)
        uint256 insertIndex = appVars.top20ContentScores.length;
        for (uint256 i = appVars.top20Contents.length - 1; i >= 0; i--) {
            if (newScore > appVars.top20ContentScores[i]) {
                insertIndex = i;
                break;
            }
        }

        // If the new score is higher than the current cap
        if (insertIndex == 0 && newScore >= CONTENT_SCORE_CAP) {
            // Dethrone the content with the previous cap
            appVars.contentDemerits[appVars.top20Contents[insertIndex].id] += CONTENT_SCORE_CAP;
            appVars.contentDemeritsTimestamp[appVars.top20Contents[insertIndex].id] = block.timestamp;

            appVars.top20ContentScores[0] = newScore;
            appVars.top20Contents[0] = appVars.contentsArray[content];
        } else if (insertIndex < appVars.top20ContentScores.length) {
            // Shift elements forward to make space for the new content

            if (insertIndex < appVars.top20Contents.length - 1){
                appVars.contentDemerits[appVars.top20Contents[insertIndex].id] = appVars.top20ContentScores[insertIndex + 1] - MIN_CONTENT_SCORE;
                appVars.contentDemeritsTimestamp[appVars.top20Contents[insertIndex].id] = block.timestamp;
            }
            else{
                appVars.contentDemerits[appVars.top20Contents[insertIndex].id] = appVars.top20ContentScores[insertIndex + 1] - appVars.top20ContentScores[insertIndex - 1];
                appVars.contentDemeritsTimestamp[appVars.top20Contents[insertIndex].id] = block.timestamp;
            }


            for (uint256 i = appVars.top20ContentScores.length - 1; i > insertIndex; i--) {
                appVars.top20ContentScores[i] = appVars.top20ContentScores[i - 1];
                appVars.top20Contents[i] = appVars.top20Contents[i - 1];
            }

            // Insert the new content at the correct position
            appVars.top20ContentScores[insertIndex] = newScore;
            appVars.top20Contents[insertIndex] = appVars.contentsArray[content];
        }
    }

    // Function to update the top 20 rankings
    function updateTopCreators(address creator, uint256 newScore) private {
        // Check if the new score qualifies for the top 20
        if (newScore < MIN_CREATOR_SCORE) {
            return;
        }

        // Find the insertion position for the new creator (start from the back)
        uint256 insertIndex = appVars.top20CreatorScores.length;
        for (uint256 i = appVars.top20CreatorScores.length - 1; i >= 0; i--) {
            if (newScore > appVars.top20CreatorScores[i]) {
                insertIndex = i;
                break;
            }
        }

        // If the new score is higher than the current cap
        if (insertIndex == 0 && newScore >= CREATOR_SCORE_CAP) {
            appVars.creatorDemerits[appVars.top20Creators[insertIndex].walletAddress] += MIN_CREATOR_SCORE;
            appVars.creatorDemeritsTimestamp[appVars.top20Creators[insertIndex].walletAddress] = block.timestamp;

            // Dethrone the creator with the previous cap
            (string memory username, address walletAddress, string memory profileImage) = authorizationContract.getUserDetails(creator);
            appVars.top20CreatorScores[0] = newScore;
            appVars.top20Creators[0] = User(username, walletAddress, profileImage);
        } else if (insertIndex < appVars.top20CreatorScores.length) {
            if (insertIndex < appVars.top20Creators.length - 1){
                appVars.creatorDemerits[appVars.top20Creators[insertIndex].walletAddress] = appVars.top20ContentScores[insertIndex + 1] - MIN_CREATOR_SCORE;
                appVars.creatorDemeritsTimestamp[appVars.top20Creators[insertIndex].walletAddress] = block.timestamp;
            }
            else{
                appVars.creatorDemerits[appVars.top20Creators[insertIndex].walletAddress] = appVars.top20ContentScores[insertIndex + 1] - appVars.top20ContentScores[insertIndex - 1];
                appVars.creatorDemeritsTimestamp[appVars.top20Creators[insertIndex].walletAddress] = block.timestamp;
            }

            // Shift elements forward to make space for the new creator
            for (uint256 i = appVars.top20CreatorScores.length - 1; i > insertIndex; i--) {
                appVars.top20CreatorScores[i] = appVars.top20CreatorScores[i - 1];
                appVars.top20Creators[i] = appVars.top20Creators[i - 1];
            }

            // Insert the new creator at the correct position
            (string memory username, address walletAddress, string memory profileImage) = authorizationContract.getUserDetails(creator);
            appVars.top20CreatorScores[insertIndex] = newScore;
            appVars.top20Creators[insertIndex] = User(username, walletAddress, profileImage);
        }
    }

    function fetchContent(uint256 lastId) public view returns (ContentItem[] memory, uint256) {
        uint256 totalContent = appVars.contentCount;

        // If no lastId provided or lastId is invalid, start from newest
        if (lastId == 0 || lastId >= totalContent) {
            lastId = totalContent - 1; // Start from the last element (newest)
        }

        uint256 startIndex = lastId;
        uint256 endIndex = startIndex + 1; 

        // Handle potential underflow for startIndex (avoiding negative index)
        if (startIndex == 0) {
            startIndex = totalContent - 1;
        }

        ContentItem[] memory returnedContents = new ContentItem[](20);
        uint256 fetchedCount = 0;

        while (fetchedCount < 20 && endIndex > 0) {
            ContentItem memory content = appVars.contentsArray[startIndex];

            if (!content.isDeleted) {
                returnedContents[fetchedCount] = appVars.contents[startIndex];
                fetchedCount++;
            }

            // Handle underflow for startIndex (loop back to the end if necessary)
            if (startIndex == 0) {
                startIndex = totalContent - 1;
            }

            startIndex--;
            endIndex--;
        }

        // Update lastId for pagination (last element retrieved)
        uint256 newLastId = startIndex;

        return (returnedContents, newLastId);
    }

    function fetchRecent20() public view returns (ContentItem[] memory) {
        uint256 totalContent = appVars.contentCount;

        uint256 startIndex = totalContent - 1;
        uint256 endIndex = startIndex + 1; 

        ContentItem[] memory returnedContents = new ContentItem[](20);
        uint256 fetchedCount = 0;

        while (fetchedCount < 20 && endIndex > 0) {
            ContentItem memory content = appVars.contentsArray[startIndex];

            if (!content.isDeleted) {
                returnedContents[fetchedCount] = appVars.contents[startIndex];
                fetchedCount++;
            }

            // Handle underflow for startIndex (loop back to the end if necessary)
            if (startIndex == 0) {
                startIndex = totalContent - 1;
            }

            startIndex--;
            endIndex--;
        }

        return returnedContents;
    }

    function fetchTopCreator() public view returns(User[] memory){
        return  appVars.top20Creators;
    }

    function fetchTendingContent() public view returns(ContentItem[] memory){
        return  appVars.top20Contents;
    }

    function fetchCreatorContent(address _creator) public view returns(ContentItem[] memory){
        return  appVars.creatorContents[_creator];
    }

    function calculateDecayFactor(uint256 creationTime) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - creationTime;

        uint256 decayFactor = INITIAL_DECAY_FACTOR - (timeElapsed * INITIAL_DECAY_FACTOR / TIMESTAMP_FACTOR);

        return decayFactor > MIN_DECAY_FACTOR ? decayFactor : MIN_DECAY_FACTOR;
    }

    // Function to calculate a content's weighted engagement score
    function calculateWeightedScore(uint256 rating, uint256 likes, uint256 dislikes, uint256 views, uint256 shares) public pure returns (uint256) {
        return (rating * weightRating) +
               (likes * weightLike * 1 ether) -
               (dislikes * weightDislike  * 1 ether) +
               (views * weightView  * 1 ether) +
               (shares * weightShare  * 1 ether);
    }

    function calculateReward() public view returns (uint256) {
        uint256 accReward= appVars.userRewardsAccumulated[msg.sender] * appVars.creatorRating[msg.sender];

        return accReward;
    }
}
