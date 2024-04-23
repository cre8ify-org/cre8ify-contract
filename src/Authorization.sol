// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Authorization {
    struct User {
        string username;
        address walletAddress;
        string profileImage; // IPFS hash or URL for profile image
    }

    mapping(address => User) public userDetails;
    mapping(address => bool) public registeredUsers;

    event UserRegistered(address indexed user, string username, string profileImage);

    // Modifier to check if user is registered
    modifier onlyRegistered() {
        require(registeredUsers[msg.sender], "User is not registered");
        _;
    }

    // Register user with their wallet address, username, and profileImage
    function registerUser(string memory _username, string memory _profileImage) public {
        require(!registeredUsers[msg.sender], "User is already registered");
        
        User memory newUser = User({
            username: _username,
            walletAddress: msg.sender,
            profileImage: _profileImage
        });

        userDetails[msg.sender] = newUser;
        registeredUsers[msg.sender] = true;
        
        emit UserRegistered(msg.sender, _username, _profileImage);
    }

    // Get user details
    function getUserDetails(address _userAddress) public view returns (string memory, address, string memory) {
        User memory user = userDetails[_userAddress];
        return (user.username, user.walletAddress, user.profileImage);
    }
}
