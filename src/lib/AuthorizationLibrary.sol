// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library AuthorizationLibrary{

    event UserRegistered(address indexed user, string username, string profileImage);
    event ProfileEdited(address indexed user, string profileImage);

    function registerUser(string memory _username, string memory _profileImage, LayoutLibrary.AuthorizationLayout storage authorizationVars) external {
        require(!authorizationVars.registeredUsers[msg.sender], "User is already registered");
        require(authorizationVars.usernameAddressTracker[_username] == address(0), "Username is already taken");
        
        AppLibrary.User memory newUser = AppLibrary.User({
            username: _username,
            walletAddress: msg.sender,
            profileImage: _profileImage
        });

        authorizationVars.userDetails[msg.sender] = newUser;
        authorizationVars.registeredUsers[msg.sender] = true;
        authorizationVars.registeredUsersArray.push(newUser);
        authorizationVars.userIndexTracker[msg.sender] = authorizationVars.userCount;
        authorizationVars.usernameAddressTracker[_username] = msg.sender;
        
        emit UserRegistered(msg.sender, _username, _profileImage);

        authorizationVars.userCount++;
    }

    function getUserDetails(address _userAddress, LayoutLibrary.AuthorizationLayout storage authorizationVars) external view returns (AppLibrary.User memory) {

        return authorizationVars.userDetails[_userAddress];
        
    }

    function getUserAddress(string memory _username, LayoutLibrary.AuthorizationLayout storage authorizationVars) external view returns (address) {
        
        return authorizationVars.usernameAddressTracker[_username];

    }

    function getAllUsers(LayoutLibrary.AuthorizationLayout storage authorizationVars) external view returns (AppLibrary.User[] memory) {
        
        return authorizationVars.registeredUsersArray;

    }

    function editProfile(string memory _newProfileImage, LayoutLibrary.AuthorizationLayout storage authorizationVars) external {
        AppLibrary.User storage user = authorizationVars.userDetails[msg.sender];

        user.profileImage = _newProfileImage;
        
        authorizationVars.registeredUsersArray[authorizationVars.userIndexTracker[msg.sender]].profileImage = _newProfileImage;
        
        emit ProfileEdited(msg.sender, _newProfileImage);
    }

    function checkRegisteredUsers(address _user, LayoutLibrary.AuthorizationLayout storage authorizationVars) external view returns(bool){
        
        return authorizationVars.registeredUsers[_user];

    }

}