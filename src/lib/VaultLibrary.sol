// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./AppLibrary.sol";
import "./LayoutLibrary.sol";

library VaultLibrary{
    
    event Tipped(address indexed creator, address indexed tipper, uint256 amount);
    event Subscribed(address indexed creator, address indexed subscriber, uint256 amount);
    event WithdrawnAccured(address indexed creator, uint256 amount);

    function tipCreator(uint256 amount, address _Tipper, address _creator, LayoutLibrary.VaultLayout storage vaultVars) public {
        
        require(vaultVars.token.balanceOf(_Tipper) >= amount, "Insufficient balance");
        
        vaultVars.token.transferFrom(_Tipper, address(this), amount);

        vaultVars.creatorAccured[_creator] += amount;

        emit Tipped(_creator, _Tipper, amount);
    }

   function subscribe(uint256 amount, address _subscriber, address _creator, LayoutLibrary.VaultLayout storage vaultVars) external {
        
        require(vaultVars.token.balanceOf(_subscriber) >= amount, "Insufficient balance");
        
        vaultVars.token.transferFrom(_subscriber, address(this), amount);

        vaultVars.creatorAccured[_creator] += amount;

        emit Subscribed(_creator, _subscriber, amount);
   }

   function CreatorPayout(uint256 amount, address _creator, LayoutLibrary.VaultLayout storage vaultVars) external {

        // To Do - calculation to share creator accured with platform 
       
       require(vaultVars.creatorAccured[_creator] >= amount, "Insufficient balance");
       
       vaultVars.creatorAccured[_creator] -= amount;

       vaultVars.token.transfer(_creator, amount);

       emit WithdrawnAccured(_creator, amount);
   }

}