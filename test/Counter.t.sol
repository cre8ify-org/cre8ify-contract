// tests/ContentManager.t.sol
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ContentManager.sol";

contract ContentManagerTest is Test {
    ContentManager contentManager;
    address contentCreatorTokenAddress = address(1);
    address contentOwner = address(2);

    function setUp() public {
        contentManager = ContentManager(address(new ContentManager(contentCreatorTokenAddress)));
    }

    function testUploadContent() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // Check that the content was uploaded successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 1);
        assertEq(userContents[0].ipfsHash, "ipfs://QmHash");
    }

    function testUpdateContent() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // Update the content
        contentManager.updateContent(0, "ipfs://NewQmHash", { from: contentOwner });

        // Check that the content was updated successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 1);
        assertEq(userContents[0].ipfsHash, "ipfs://NewQmHash");
    }

    function testDeleteContent() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // Delete the content
        contentManager.deleteContent(0, { from: contentOwner });

        // Check that the content was deleted successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 0);
    }

    function testViewContent() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // View the content
        contentManager.viewContent(0, { from: contentOwner });

        // Check that the content was viewed successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 1);
        assertEq(userContents[0].views, 1);
    }

    function testLikeContent() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // Like the content
        contentManager.likeContent(0, { from: contentOwner });

        // Check that the content was liked successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 1);
        assertEq(userContents[0].likes, 1);
    }

    function testCommentContent() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // Comment on the content
        contentManager.commentContent(0, { from: contentOwner });

        // Check that the content was commented on successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 1);
        assertEq(userContents[0].comments, 1);
    }

    function testInviteCollaborator() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // Invite a collaborator
        contentManager.inviteCollaborator(0, address(3), { from: contentOwner });

        // Check that the collaborator was invited successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 1);
        assertEq(userContents[0].collaborators.length, 1);
        assertEq(userContents[0].collaborators[0], address(3));
    }

    function testRemoveCollaborator() public {
        // Upload some content
        contentManager.uploadContent("ipfs://QmHash", { from: contentOwner });

        // Invite a collaborator
        contentManager.inviteCollaborator(0, address(3), { from: contentOwner });

        // Remove the collaborator
        contentManager.removeCollaborator(0, address(3), { from: contentOwner });

        // Check that the collaborator was removed successfully
        Content[] memory userContents = contentManager.userContent(contentOwner);
        assertEq(userContents.length, 1);
        assertEq(userContents[0].collaborators.length, 0);
    }

    function testDistributeRevenueToCollaborators() public {
        // Upload some content
        contentManager.uploadContent("