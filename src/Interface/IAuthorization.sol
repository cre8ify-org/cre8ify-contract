// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/AppLibrary.sol";

interface IAuthorization {
    /**
     * @notice Get the details of a user
     * @param _userAddress The address of the user
     * @return AppLibrary.User The details of the user
     */
    function getUserDetails(address _userAddress) external view returns (AppLibrary.User memory);

    /**
     * @notice Check if a user is a registered user
     * @param _user The address of the user
     * @return bool True if the user is registered, false otherwise
     */
    function checkRegisteredUsers(address _user) external view returns (bool);

    /**
     * @notice Register a new user in the system
     * @param username The username of the user
     * @param walletAddress The wallet address of the user
     * @param profileImage A link to the user's profile image
     */
    function registerUser(string memory username, address walletAddress, string memory profileImage) external;

    /**
     * @notice Update an existing user's profile
     * @param _userAddress The address of the user
     * @param username The updated username
     * @param profileImage The updated profile image
     */
    function updateUserProfile(address _userAddress, string memory username, string memory profileImage) external;
}
