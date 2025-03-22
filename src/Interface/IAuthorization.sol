// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/AppLibrary.sol";

interface IAuthorization {
    // Get user details
    function getUserDetails(
        address _userAddress
    ) external view returns (AppLibrary.User memory);

    function checkRegisteredUsers(address _user) external view returns (bool);

    function owner() external view returns (address);
}
