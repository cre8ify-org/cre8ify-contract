// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
This contract handles the security and moderation features of the platform.
 It includes a bannedUsers mapping to track banned users, and a reportContent 
 function for users to report inappropriate content. The contract uses the OpenZeppelin AccessControl 
 library to manage the MODERATOR_ROLE, which allows specific users to ban and unban other users.
 */

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract SecurityManager is AccessControl {
    IERC20 public contentCreatorToken;

    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

    mapping(address => bool) public bannedUsers;

    constructor(address _contentCreatorToken) {
        contentCreatorToken = IERC20(_contentCreatorToken);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function banUser(address _user) public onlyRole(MODERATOR_ROLE) {
        bannedUsers[_user] = true;
    }

    function unbanUser(address _user) public onlyRole(MODERATOR_ROLE) {
        bannedUsers[_user] = false;
    }

    modifier onlyUnbanned() {
        require(!bannedUsers[msg.sender], "User is banned");
        _;
    }

    function reportContent(uint256 _contentId, address _contentOwner) public onlyUnbanned {
        require(contentCreatorToken.balanceOf(msg.sender) >= 50 * 10 ** 18, "Insufficient token balance");
        // Implement content reporting logic
        contentCreatorToken.transferFrom(msg.sender, _contentOwner, 50 * 10 ** 18);
    }
}