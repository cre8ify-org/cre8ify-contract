pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 public subscriptionAmount;

   constructor(string memory name, string memory symbol, uint256 initialSupply, uint256 _subscriptionAmount) ERC20(name, symbol) {
    _mint(msg.sender, 10000000000000000000); // Increase initial supply to 10 trillion tokens
    subscriptionAmount = _subscriptionAmount;
}

    function subscribe() external {
        require(balanceOf(msg.sender) >= subscriptionAmount, "Insufficient balance");
        _burn(msg.sender, subscriptionAmount);
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function totalSupply() public pure override returns (uint256) {
        return 0; // Return 0 for unlimited tokens
    }
}