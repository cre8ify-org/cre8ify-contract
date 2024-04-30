// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
   constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 10000000000000000000); 
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function totalSupply() public pure override returns (uint256) {
        return 0; // Return 0 for unlimited tokens
    }
}