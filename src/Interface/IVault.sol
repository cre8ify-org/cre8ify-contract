// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault {
    // Tip a creator using platform tokens
    function tipCreator(uint256 amount, address _tipper, address _creator) external;

    // Payout to the creator
    function CreatorPayout(uint256 amount, address _creator) external;
}
