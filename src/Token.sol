pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 public subscriptionAmount;

    constructor(string memory name, string memory symbol, uint256 _initialSupply, uint256 _subscriptionAmount) ERC20(name, symbol) {
        _mint(msg.sender, _initialSupply);
        subscriptionAmount = _subscriptionAmount;
    }

    function subscribe() external {
        require(balanceOf(msg.sender) >= subscriptionAmount, "Insufficient balance");

        _burn(msg.sender, subscriptionAmount);
    }

    function mint(address account, uint256 amount) external  {
        _mint(account, amount);
    }
    
}
