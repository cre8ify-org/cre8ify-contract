// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**

This contract handles user profiles, including the creation, update,
 and social features like following and unfollowing other users. 
 Users need to hold a minimum amount of tokens to create a profile and perform certain actions.
 */
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ProfileManager is Ownable {
    IERC20 public contentCreatorToken;

    struct Profile {
        string username;
        string bio;
        string avatar;
        uint256 followers;
        uint256 following;
    }

    mapping(address => Profile) public userProfiles;

    constructor(address _contentCreatorToken) {
        contentCreatorToken = IERC20(_contentCreatorToken);
    }

    function createProfile(string memory _username, string memory _bio, string memory _avatar) public {
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(contentCreatorToken.balanceOf(msg.sender) >= 50 * 10 ** 18, "Insufficient token balance");
        contentCreatorToken.transferFrom(msg.sender, address(this), 50 * 10 ** 18);

        Profile storage newProfile = userProfiles[msg.sender];
        newProfile.username = _username;
        newProfile.bio = _bio;
        newProfile.avatar = _avatar;
        newProfile.followers = 0;
        newProfile.following = 0;
    }

    function updateProfile(string memory _bio, string memory _avatar) public {
        Profile storage profile = userProfiles[msg.sender];
        profile.bio = _bio;
        profile.avatar = _avatar;
    }

    function followUser(address _user) public {
        require(contentCreatorToken.balanceOf(msg.sender) >= 10 * 10 ** 18, "Insufficient token balance");
        contentCreatorToken.transferFrom(msg.sender, _user, 10 * 10 ** 18);
        userProfiles[_user].followers++;
        userProfiles[msg.sender].following++;
    }

    function unfollowUser(address _user) public {
        userProfiles[_user].followers--;
        userProfiles[msg.sender].following--;
    }
}