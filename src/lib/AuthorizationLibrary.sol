// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library AuthorizationLibrary {
    event UserRegistered(address indexed user, string username, string profileImage);
    event ProfileEdited(address indexed user, string profileImage);
    event TipSent(address indexed tipper, address indexed recipient, uint256 amount, uint256 timestamp);

    function registerUser(
        string memory _username,
        string memory _profileImage,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external {
        require(!authorizationVars.registeredUsers[msg.sender], "User is already registered");
        require(authorizationVars.usernameAddressTracker[_username] == address(0), "Username is already taken");

        AppLibrary.User memory newUser = AppLibrary.User({
            username: _username,
            walletAddress: msg.sender,
            profileImage: _profileImage,
            totalTipsReceived: 0, // Initialize tips received to zero
            badges: new stringInitialize with no badges
        });

        authorizationVars.userDetails[msg.sender] = newUser;
        authorizationVars.registeredUsers[msg.sender] = true;
        authorizationVars.registeredUsersArray.push(newUser);
        authorizationVars.userIndexTracker[msg.sender] = authorizationVars.userCount;
        authorizationVars.usernameAddressTracker[_username] = msg.sender;

        emit UserRegistered(msg.sender, _username, _profileImage);

        authorizationVars.userCount++;
    }

    function getUserDetails(
        address _userAddress,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external view returns (AppLibrary.User memory) {
        return authorizationVars.userDetails[_userAddress];
    }

    function getUserAddress(
        string memory _username,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external view returns (address) {
        return authorizationVars.usernameAddressTracker[_username];
    }

    function getAllUsers(
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external view returns (AppLibrary.User[] memory) {
        return authorizationVars.registeredUsersArray;
    }

    function editProfile(
        string memory _newProfileImage,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external {
        AppLibrary.User storage user = authorizationVars.userDetails[msg.sender];

        user.profileImage = _newProfileImage;

        authorizationVars.registeredUsersArray[authorizationVars.userIndexTracker[msg.sender]].profileImage = _newProfileImage;

        emit ProfileEdited(msg.sender, _newProfileImage);
    }

    function checkRegisteredUsers(
        address _user,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external view returns (bool) {
        return authorizationVars.registeredUsers[_user];
    }

    function tipUser(
        address _recipient,
        uint256 _amount,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external {
        require(authorizationVars.registeredUsers[_recipient], "Recipient must be a registered user");
        require(_amount > 0, "Tip amount must be greater than zero");

        AppLibrary.User storage recipient = authorizationVars.userDetails[_recipient];
        recipient.totalTipsReceived += _amount;

        authorizationVars.tipHistory[_recipient].push(AppLibrary.TippingInfo({
            tipper: msg.sender,
            amount: _amount,
            timestamp: block.timestamp
        }));

        emit TipSent(msg.sender, _recipient, _amount, block.timestamp);
    }

    function fetchTippingHistory(
        address _user,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external view returns (AppLibrary.TippingInfo[] memory) {
        return authorizationVars.tipHistory[_user];
    }

    function fetchTotalTipsReceived(
        address _user,
        LayoutLibrary.AuthorizationLayout storage authorizationVars
    ) external view returns (uint256) {
        return authorizationVars.userDetails[_user].totalTipsReceived;
    }
}
