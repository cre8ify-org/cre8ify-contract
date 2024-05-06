// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {CCP} from "../src/CCP2.sol";

contract CCPScript is Script {
    CCP public dCCP;
    address token = 0xfd4CcC782Dbc259ACD5465927bdf09daAfD5Aa9e;
    address subscription = 0xfd4CcC782Dbc259ACD5465927bdf09daAfD5Aa9e;
    address authorization = 0xfd4CcC782Dbc259ACD5465927bdf09daAfD5Aa9e;

    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey); 
        dCCP = new CCP(authorization, subscription, token);
        vm.stopBroadcast();
    }
}