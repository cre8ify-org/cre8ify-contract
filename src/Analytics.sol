// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/AnalyticsLibrary.sol";

contract Analytics {
    LayoutLibrary.AnalyticsLayout internal analyticsVars;

    // Events
    event TipTracked(
        address indexed creator,
        uint256 amount,
        uint256 timestamp
    );
    event BadgeAwarded(address indexed user, string badge, uint256 timestamp);
    event CCPContractChanged(address indexed newCCPContract);

    constructor(address _ccpContract) {
        analyticsVars.ccpContract = _ccpContract;
        analyticsVars.owner = msg.sender;
    }

    modifier onlyCCPContract() {
        require(analyticsVars.ccpContract == msg.sender, "Only CCP contract");
        _;
    }

    modifier onlyOwner() {
        require(analyticsVars.owner == msg.sender, "Only owner");
        _;
    }

    // Change the CCP contract address
    function changeCCPContract(address _ccp) external onlyOwner {
        analyticsVars.ccpContract = _ccp;
        emit CCPContractChanged(_ccp);
    }

    // Track tipping events
    function trackTip(
        address _creator,
        uint256 _amount
    ) external onlyCCPContract {
        analyticsVars.creatorTips[_creator] += _amount;
        emit TipTracked(_creator, _amount, block.timestamp);
    }

    // Added back engagement tracking functions
    // Track free content likes
    function trackFreeLike(uint256 _id) external onlyCCPContract {
        analyticsVars.freeLikes[_id]++;
    }

    // Track free content dislikes
    function trackFreeDislike(uint256 _id) external onlyCCPContract {
        analyticsVars.freeDislikes[_id]++;
    }

    // Track free content ratings
    function trackFreeRating(
        uint256 _id,
        uint256 _rating
    ) external onlyCCPContract {
        analyticsVars.freeRatings[_id] = _rating;
    }

    // Commented out exclusive content tracking
    // Track exclusive content likes
    // function trackExclusiveLike(uint256 _id) external onlyCCPContract {
    //     analyticsVars.exclusiveLikes[_id]++;
    // }

    // Track exclusive content dislikes
    // function trackExclusiveDislike(uint256 _id) external onlyCCPContract {
    //     analyticsVars.exclusiveDislikes[_id]++;
    // }

    // Track exclusive content ratings
    // function trackExclusiveRating(
    //     uint256 _id,
    //     uint256 _rating
    // ) external onlyCCPContract {
    //     analyticsVars.exclusiveRatings[_id] = _rating;
    // }

    // Track creator rating
    function trackCreatorRating(
        address _creator,
        uint256 _rating
    ) external onlyCCPContract {
        analyticsVars.creatorRatings[_creator] = _rating;
    }

    // Track creator followers
    function trackFollower(
        address _creator,
        bool inc
    ) external onlyCCPContract {
        if (inc) {
            analyticsVars.follower[_creator]++;
        } else {
            analyticsVars.follower[_creator]--;
        }
    }

    // Fetch total tips for a creator
    function getCreatorTips(address _creator) external view returns (uint256) {
        return analyticsVars.creatorTips[_creator];
    }

    // Fetch top tippers
    function getTopTippers(
        uint256 _limit
    ) external view returns (address[] memory, uint256[] memory) {
        // Implement logic to fetch top tippers (e.g., using off-chain indexing)
        address[] memory tippers = new address[](_limit);
        uint256[] memory amounts = new uint256[](_limit);
        // Placeholder logic
        for (uint256 i = 0; i < _limit; i++) {
            tippers[i] = address(uint160(i));
            amounts[i] = analyticsVars.creatorTips[tippers[i]];
        }
        return (tippers, amounts);
    }

    // Fetch top creators
    function getTopCreators(
        uint256 _limit
    ) external view returns (address[] memory, uint256[] memory) {
        // Implement logic to fetch top creators (e.g., using off-chain indexing)
        address[] memory creators = new address[](_limit);
        uint256[] memory amounts = new uint256[](_limit);
        // Placeholder logic
        for (uint256 i = 0; i < _limit; i++) {
            creators[i] = address(uint160(i));
            amounts[i] = analyticsVars.creatorTips[creators[i]];
        }
        return (creators, amounts);
    }

    // Fetch badges for a user
    function getUserBadges(
        address _user
    ) external view returns (string[] memory) {
        return analyticsVars.userBadges[_user];
    }

    // Get free content analytics
    function getFreeContentAnalytics(
        uint256 _id
    )
        external
        view
        onlyCCPContract
        returns (AppLibrary.ContentAnalytics memory)
    {
        return AnalyticsLibrary.getFreeContentAnalytics(_id, analyticsVars);
    }

    // Commented out exclusive content analytics
    // function getExclusiveContentAnalytics(
    //     uint256 _id
    // ) external view onlyCCPContract returns (AppLibrary.ContentAnalytics memory) {
    //     return AnalyticsLibrary.getExclusiveContentAnalytics(_id, analyticsVars);
    // }

    // Get creator analytics
    function getCreatorAnalytics(
        address _creator
    ) public view onlyCCPContract returns (AppLibrary.CreatorAnalytics memory) {
        return AnalyticsLibrary.getCreatorAnalytics(_creator, analyticsVars);
    }
}
