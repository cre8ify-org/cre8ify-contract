// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/AppLibrary.sol";
import "./lib/LayoutLibrary.sol";
import "./lib/AuthorizationLibrary.sol";

contract Authorization {

    LayoutLibrary.AuthorizationLayout internal authorizationVars;

    // Modifier to check if user is registered
    modifier onlyRegistered() {
        require(authorizationVars.registeredUsers[msg.sender], "AppLibrary.User is not registered");
        _;
    }

    // Register user with their wallet address, username, and profileImage
    function registerUser(string memory _username, string memory _profileImage) public {
        
        AuthorizationLibrary.registerUser(_username, _profileImage, authorizationVars);

    }

    // Get user details
    function getUserDetails(address _userAddress) public view returns (AppLibrary.User memory) {
        
        return AuthorizationLibrary.getUserDetails(_userAddress, authorizationVars);

    }

    // Get user address by username
    function getUserAddress(string memory _username) public view returns (address) {

        return AuthorizationLibrary.getUserAddress(_username, authorizationVars);

    }

    // Get all registered users
    function getAllUsers() public view returns (AppLibrary.User[] memory) {

        return AuthorizationLibrary.getAllUsers(authorizationVars);

    }

    // Edit creator profile
    function editProfile(string memory _newProfileImage) public onlyRegistered {
        
        AuthorizationLibrary.editProfile(_newProfileImage, authorizationVars);

    }

    // Confirm user registration
    function checkRegisteredUsers(address _user) external view returns(bool){

        return AuthorizationLibrary.checkRegisteredUsers(_user, authorizationVars);

    }
}