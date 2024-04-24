// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import "../src/Subscription.sol";
import "../src/DAO.sol";
import "../src/Content.sol";
import "../src/Authorization.sol";
import "../src/Analytics.sol";
import "../src/Token.sol";
import "../src/Strings.sol";

contract TestContract is Test {
    Subscription public subscriptionContract;
    DAO public daoContract;
    Content public contentContract;
    Authorization public authorizationContract;
    Analytics public analyticsContract;
    Token public tokenContract;

    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(1);
        user2 = address(2);
        tokenContract = new Token("Token", "TKN", 10000000000, 10);
        subscriptionContract = new Subscription(address(tokenContract));
        contentContract = new Content(address(subscriptionContract), address(daoContract));
        daoContract = new DAO(address(this), address(contentContract), address(tokenContract));
        authorizationContract = new Authorization();
        analyticsContract = new Analytics();
    }

function testSubscription() public {
    tokenContract.approve(address(subscriptionContract), 1000000000000000000);
    tokenContract.mint(user1, 1000000000); // Mint 1 billion tokens
    subscriptionContract.subscribe(1);
    assertTrue(subscriptionContract.isSubscribed(user1)); // Check if user1 is subscribed
    uint256 expiryTime = subscriptionContract.subscriptionExpiry(user1);
    assertEq(expiryTime, block.timestamp + 2); // Check if expiry time is correct
    subscriptionContract.extendSubscription(1);
    assertEq(subscriptionContract.subscriptionExpiry(user1), expiryTime + 1); // Check if expiry time is extended correctly
    subscriptionContract.renewSubscription(1);
    assertEq(subscriptionContract.subscriptionExpiry(user1), block.timestamp + 1); // Check if expiry time is renewed correctly
}

function testDAO() public {
    authorizationContract.registerUser("TestUser", "(link unavailable)");
    daoContract.registerUser("TestUser", Strings.toString(address(this)));
    daoContract.submitProposal("Test proposal", DAO.ProposalType.ContentModeration);
    assertEq(daoContract.proposalCount(), 1);
    daoContract.vote(1, true);
    assertEq(daoContract.getYesVotes(1), 1);
    daoContract.executeProposal(1, DAO.ProposalType.ContentModeration);
    assertTrue(daoContract.isProposalExecuted(1));
}

    function testContent() public {
        address userAddress = authorizationContract.getUserAddress("TestUser");
        assertTrue(userAddress != address(0));
contentContract.createContent("Test content", "ipfs://test", "text/plain");
        assertEq(contentContract.contentCount(), 1);
        contentContract.monetizeContent(1);
        assertTrue(contentContract.isContentMonetized(1));
        contentContract.viewContent(1);
    }

    function testAuthorization() public {
        authorizationContract.registerUser("TestUser", "(link unavailable)");
        assertTrue(authorizationContract.registeredUsers(user1));
        (string memory username, address userAddress, string memory profileImage) = authorizationContract.getUserDetails(user1);
        assertEq(username, "TestUser");
        assertEq(userAddress, user1);
        assertEq(profileImage, "(link unavailable)");

        authorizationContract.editProfile("NewUsername", "(new link)");
        (username, userAddress, profileImage) = authorizationContract.getUserDetails(user1);
        assertEq(username, "NewUsername");
        assertEq(userAddress, user1);
        assertEq(profileImage, "(new link)");
    }

    function testAnalytics() public {
        analyticsContract.trackView(1);
        assertEq(analyticsContract.views(1), 1);

        analyticsContract.trackLike(1);
        assertEq(analyticsContract.likes(1), 1);

        analyticsContract.trackRating(1, 5);
        assertEq(analyticsContract.ratings(1), 5);
    }

   function testToken() public {
    tokenContract.subscribe();
    assertEq(tokenContract.balanceOf(user1), 0);

    tokenContract.mint(user1, 10000000000); // Mint a large amount of tokens
    assertEq(tokenContract.balanceOf(user1), 10000000000);
}
// function testWithdrawReward() public {
//     contentContract.createContent("Test content", "ipfs://test", "text/plain");
//     contentContract.monetizeContent(1);
//     contentContract.viewContent(1);
//     contentContract.likeContent(1);
//     uint256 reward = contentContract.calculateReward(1);
//     payable(contentContract.contents(1).creatorProfile).transfer(reward);
//     assertEq(address(contentContract.contents(1).creator).balance, reward);
// }
}