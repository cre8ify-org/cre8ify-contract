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
    address[] public registeredUserAddresses; // Array to store registered user addresses

    event UserRegistered(address indexed user, string username, string profileImage);
    event ProfileEdited(address indexed user, string username, string profileImage);

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
        registeredUserAddresses.push(msg.sender); // Add user address to the array
        
        emit UserRegistered(msg.sender, _username, _profileImage);
    }

    // Get user details
    function getUserDetails(address _userAddress) public view returns (string memory, address, string memory) {
        User memory user = userDetails[_userAddress];
        return (user.username, user.walletAddress, user.profileImage);
    }

    // Get user address by username
    function getUserAddress(string memory _username) public view returns (address) {
        for (uint256 i = 0; i < registeredUserAddresses.length; i++) {
            if (keccak256(abi.encodePacked(userDetails[registeredUserAddresses[i]].username)) == keccak256(abi.encodePacked(_username))) {
                return registeredUserAddresses[i];
            }
        }
        return address(0);
    }

    // Get all registered users
    function getAllUsers() public view returns (address[] memory) {
        return registeredUserAddresses;
    }

    // Edit creator profile
    function editProfile(string memory _newUsername, string memory _newProfileImage) public onlyRegistered {
        User storage user = userDetails[msg.sender];
        user.username = _newUsername;
        user.profileImage = _newProfileImage;
        emit ProfileEdited(msg.sender, _newUsername, _newProfileImage);
    }
}