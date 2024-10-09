// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/AppLibrary.sol";

import "./lib/LayoutLibrary.sol";
import "./lib/VaultLibrary.sol";

contract Vault {

    LayoutLibrary.VaultLayout internal vaultVars;

    constructor(address _tokenAddress) {
        vaultVars.token = IERC20(_tokenAddress);
    }

    function tipCreator(uint256 _amount, address _tipper, address _creator) public {

         VaultLibrary.tipCreator(_amount, _tipper, _creator, vaultVars);

    }

    function subscribe(uint256 _amount, address _subscriber, address _creator) external {
            
        VaultLibrary.subscribe(_amount, _subscriber, _creator, vaultVars);

    }

    function CreatorPayout(uint256 _amount, address _creator) external {
        
        VaultLibrary.CreatorPayout(_amount, _creator, vaultVars);
        
    }

}