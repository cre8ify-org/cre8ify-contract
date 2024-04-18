// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
This contract allows content creators to collaborate with other users on their content.
 It enables the creation of collaborations, the joining of collaborators, 
 and the distribution of revenue based on the agreed-upon revenue share.
 */

 
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract CollaborationManager is Ownable {
    IERC20 public contentCreatorToken;

    struct Collaboration {
        uint256 contentId;
        address[] collaborators;
        uint256 revenueShare;
    }

    mapping(uint256 => Collaboration) public contentCollaborations;

    constructor(address _contentCreatorToken) {
        contentCreatorToken = IERC20(_contentCreatorToken);
    }

    function initiateCollaboration(uint256 _contentId, address[] memory _collaborators, uint256 _revenueShare) public {
        require(ContentManager(msg.sender).userContent(msg.sender, _contentId).owner == msg.sender, "Only the content owner can initiate a collaboration");
        require(_revenueShare <= 100, "Revenue share cannot exceed 100%");

        Collaboration storage newCollaboration = contentCollaborations[_contentId];
        newCollaboration.contentId = _contentId;
        newCollaboration.collaborators = _collaborators;
        newCollaboration.revenueShare = _revenueShare;
    }

    function joinCollaboration(uint256 _contentId) public {
        Collaboration storage collaboration = contentCollaborations[_contentId];
        require(collaboration.collaborators.length < 5, "Maximum number of collaborators reached");
        require(!isCollaborator(msg.sender, _contentId), "User is already a collaborator");

        collaboration.collaborators.push(msg.sender);
    }

    function isCollaborator(address _user, uint256 _contentId) internal view returns (bool) {
        Collaboration storage collaboration = contentCollaborations[_contentId];
        for (uint256 i = 0; i < collaboration.collaborators.length; i++) {
            if (collaboration.collaborators[i] == _user) {
                return true;
            }
        }
        return false;
    }

    function distributeRevenue(uint256 _contentId) public {
        Collaboration storage collaboration = contentCollaborations[_contentId];
        uint256 totalRevenue = contentCreatorToken.balanceOf(address(this));
        uint256 revenuePerCollaborator = totalRevenue * collaboration.revenueShare / 100 / collaboration.collaborators.length;

        for (uint256 i = 0; i < collaboration.collaborators.length; i++) {
            contentCreatorToken.transfer(collaboration.collaborators[i], revenuePerCollaborator);
        }
    }
}