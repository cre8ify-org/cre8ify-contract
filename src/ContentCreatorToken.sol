// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract ContentCreatorToken is ERC20, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10 ** 18;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        _mint(to, amount);
    }
}