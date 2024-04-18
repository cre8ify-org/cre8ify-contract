// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
This contract handles the content management features of the platform. 
Users can upload, update, and delete their content, and other users can view, like, and comment on the content. 
The contract also tracks the number of views, likes, and comments for each piece of content, and rewards the content creator with tokens based on the engagement */

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ContentManager is Ownable {
    IERC20 public contentCreatorToken;

    struct Content {
        string ipfsHash;
        uint256 createdAt;
        uint256 updatedAt;
        uint256 views;
        uint256 likes;
        uint256 comments;
        address[] collaborators;
        mapping(address => bool) hasCollaborated;
    }

    mapping(address => Content[]) public userContent;

    constructor(address _contentCreatorToken) {
        contentCreatorToken = IERC20(_contentCreatorToken);
    }

    function uploadContent(string memory _ipfsHash) public {
        require(contentCreatorToken.balanceOf(msg.sender) >= 100 * 10 ** 18, "Insufficient token balance");
        Content memory newContent = Content({
            ipfsHash: _ipfsHash,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            views: 0,
            likes: 0,
            comments: 0,
            collaborators: new address[](0)
        });
        userContent[msg.sender].push(newContent);
    }

    function updateContent(uint256 _index, string memory _ipfsHash) public {
        Content storage content = userContent[msg.sender][_index];
        content.ipfsHash = _ipfsHash;
        content.updatedAt = block.timestamp;
    }

    function deleteContent(uint256 _index) public {
        delete userContent[msg.sender][_index];
    }

    function viewContent(uint256 _index) public {
        Content storage content = userContent[msg.sender][_index];
        content.views++;
        contentCreatorToken.transfer(msg.sender, 10 * 10 ** 18);
    }

    function likeContent(uint256 _index) public {
        Content storage content = userContent[msg.sender][_index];
        content.likes++;
        contentCreatorToken.transfer(msg.sender, 5 * 10 ** 18);
    }

    function commentContent(uint256 _index) public {
        Content storage content = userContent[msg.sender][_index];
        content.comments++;
        contentCreatorToken.transfer(msg.sender, 3 * 10 ** 18);
    }

    function inviteCollaborator(uint256 _index, address _collaborator) public {
        Content storage content = userContent[msg.sender][_index];
        require(!content.hasCollaborated[_collaborator], "Collaborator already added");
        content.collaborators.push(_collaborator);
        content.hasCollaborated[_collaborator] = true;
    }

    function removeCollaborator(uint256 _index, address _collaborator) public {
        Content storage content = userContent[msg.sender][_index];
        require(content.hasCollaborated[_collaborator], "Collaborator not found");
        for (uint256 i = 0; i < content.collaborators.length; i++) {
            if (content.collaborators[i] == _collaborator) {
                content.collaborators[i] = content.collaborators[content.collaborators.length - 1];
                content.collaborators.pop();
                content.hasCollaborated[_collaborator] = false;
                break;
            }
        }
    }

    function distributeRevenueToCollaborators(uint256 _index) public {
        Content storage content = userContent[msg.sender][_index];
        uint256 totalRevenue = contentCreatorToken.balanceOf(address(this));
        uint256 revenuePerCollaborator = totalRevenue / (content.collaborators.length + 1);

        contentCreatorToken.transfer(msg.sender, revenuePerCollaborator);
        for (uint256 i = 0; i < content.collaborators.length; i++) {
            contentCreatorToken.transfer(content.collaborators[i], revenuePerCollaborator);
        }
    }
}