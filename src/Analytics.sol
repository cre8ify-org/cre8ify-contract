// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/AnalyticsLibrary.sol";

contract Analytics {
    // Mappings to track total tips and tip counts for each creator
    mapping(address => uint256) private creatorTotalTips;
    mapping(address => uint256) private creatorTipCount;

    event TipRecorded(
        address indexed creator,
        uint256 amount,
        uint256 totalTips,
        uint256 tipCount
    );

    LayoutLibrary.AnalyticsLayout internal analyticsVars;

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

    // Track free content likes
    function trackFreeLike(uint256 _id) external onlyCCPContract {
        AnalyticsLibrary.trackFreeLike(_id, analyticsVars);
    }

    // Track free content dislikes
    function trackFreeDislike(uint256 _id) external onlyCCPContract {
        AnalyticsLibrary.trackFreeDislike(_id, analyticsVars);
    }

    // Track free content ratings
    function trackFreeRating(
        uint256 _id,
        uint256 _rating
    ) external onlyCCPContract {
        AnalyticsLibrary.trackFreeRating(_id, _rating, analyticsVars);
    }

    // Track  exclusive content likes
    function trackExclusiveLike(uint256 _id) external onlyCCPContract {
        AnalyticsLibrary.trackExclusiveLike(_id, analyticsVars);
    }

    // Track exclusive content dislikes
    function trackExclusiveDislike(uint256 _id) external onlyCCPContract {
        AnalyticsLibrary.trackExclusiveDislike(_id, analyticsVars);
    }

    // Track exclusive content ratings
    function trackExclusiveRating(
        uint256 _id,
        uint256 _rating
    ) external onlyCCPContract {
        AnalyticsLibrary.trackExclusiveRating(_id, _rating, analyticsVars);
    }

    // Track creator followers
    function trackFollower(
        address _creator,
        bool _inc
    ) external onlyCCPContract {
        AnalyticsLibrary.trackFollower(_creator, _inc, analyticsVars);
    }

    // Track creator rating
    function trackCreatorRating(
        address _creator,
        uint256 _rating
    ) external onlyCCPContract {
        AnalyticsLibrary.trackCreatorRating(_creator, _rating, analyticsVars);
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

    // Get exclusive content analytics
    function getExclusiveContentAnalytics(
        uint256 _id
    )
        external
        view
        onlyCCPContract
        returns (AppLibrary.ContentAnalytics memory)
    {
        return
            AnalyticsLibrary.getExclusiveContentAnalytics(_id, analyticsVars);
    }

    // Get creator analytics
    function getCreatorAnalytics(
        address _creator
    ) public view onlyCCPContract returns (AppLibrary.CreatorAnalytics memory) {
        return AnalyticsLibrary.getCreatorAnalytics(_creator, analyticsVars);
    }

    // Change authorization contract
    function changeCCPContract(address _ccp) public onlyOwner {
        analyticsVars.ccpContract = _ccp;
    }

    // Record tips for a creator
    function recordTip(
        address _creator,
        uint256 _amount
    ) external onlyCCPContract {
        require(_amount > 0, "Tip amount must be greater than zero");

        // Update total tips and tip count for the creator
        creatorTotalTips[_creator] += _amount;
        creatorTipCount[_creator]++;

        emit TipRecorded(
            _creator,
            _amount,
            creatorTotalTips[_creator],
            creatorTipCount[_creator]
        );
    }

    // Get total tips received by a creator
    function getCreatorTotalTips(
        address _creator
    ) public view returns (uint256) {
        return creatorTotalTips[_creator];
    }

    // Get total tip count for a creator
    function getCreatorTipCount(
        address _creator
    ) public view returns (uint256) {
        return creatorTipCount[_creator];
    }
}
