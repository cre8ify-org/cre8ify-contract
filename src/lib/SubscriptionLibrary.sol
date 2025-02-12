// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library SubscriptionLibrary {
    event Subscribed(
        address indexed creator,
        address indexed subscriber,
        uint256 indexed timeSubscribed,
        uint256 expiry
    );

    function setMonthlySubscriptionAmount(
        uint256 _amount,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external {
        subscriptionVars.creatorSubscriptionAmount[msg.sender] = _amount;
    }

    function tipCreator(
        address _creator,
        uint256 amount,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external {
        subscriptionVars.vault.tipCreator(amount, msg.sender, _creator);
    }

    function fetchSubscribers(
        address _creator,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external view returns (AppLibrary.User[] memory) {
        return subscriptionVars.creatorSubscribers[_creator];
    }

    function fetchSubscribedTo(
        address _subscriber,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external view returns (AppLibrary.User[] memory) {
        return subscriptionVars.SubscribedTo[_subscriber];
    }

    function getCreatorSubscriptionAmount(
        address _creator,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external view returns (uint256) {
        return subscriptionVars.creatorSubscriptionAmount[_creator];
    }

    function subscribeToCreator(
        address _creator,
        uint256 _amount,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external {
        require(
            !subscriptionVars.isSubscribedToCreator[_creator][msg.sender] &&
                !(subscriptionVars.subscriptionToCreatorExpiry[_creator][
                    msg.sender
                ] >= block.timestamp),
            "AppLibrary.User is already subscribed"
        );
        require(
            _amount == subscriptionVars.creatorSubscriptionAmount[_creator],
            "Amount doesn't match creator requirement"
        );

        uint256 subDays = 30 days;

        subscriptionVars.isSubscribedToCreator[_creator][msg.sender] = true;
        subscriptionVars.subscriptionToCreatorExpiry[_creator][msg.sender] =
            block.timestamp +
            subDays;

        subscriptionVars.vault.subscribe(_amount, msg.sender, _creator);

        subscriptionVars.subscriptionToCreatorExpiry[_creator][msg.sender] =
            block.timestamp +
            subDays;

        AppLibrary.User memory subscriberUser = subscriptionVars
            .authorizationContract
            .getUserDetails(msg.sender);

        AppLibrary.User memory creatorUser = subscriptionVars
            .authorizationContract
            .getUserDetails(_creator);

        subscriptionVars.creatorSubscribers[_creator].push(subscriberUser);
        subscriptionVars.SubscribedTo[msg.sender].push(creatorUser);

        emit Subscribed(
            _creator,
            msg.sender,
            block.timestamp,
            subscriptionVars.subscriptionToCreatorExpiry[_creator][msg.sender]
        );
    }

    function checkSubscribtionToCreatorStatus(
        address _creator,
        address _subscriber,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external view returns (bool) {
        if (
            subscriptionVars.isSubscribedToCreator[_creator][_subscriber] &&
            (subscriptionVars.subscriptionToCreatorExpiry[_creator][
                _subscriber
            ] >= block.timestamp)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function payout(
        uint256 _amount,
        address _creator,
        LayoutLibrary.SubscriptionLayout storage subscriptionVars
    ) external {
        subscriptionVars.vault.CreatorPayout(_amount, _creator);
    }
}
