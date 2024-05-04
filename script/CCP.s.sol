// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Analytics} from "../src/Analytics.sol";
import {Authorization} from "../src/Authorization.sol";
import {Token} from "../src/Token.sol";
import {Subscription} from "../src/Subscription.sol";
import {CCP} from "../src/CCP1.sol";

contract CCPScript is Script {
    Analytics public dAnalytics;
    Authorization public dAuthorization;
    Token public dToken;
    Subscription public dSubscription;
    CCP public dCCP;
    

    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        dAnalytics = new Analytics();
        dAuthorization = new Authorization();
        dToken = new Token("ConntentCP", "CCP");
        dSubscription = new Subscription(address(dToken));
        dCCP = new CCP(address(dAuthorization), address(dAnalytics), address(dSubscription));
        vm.stopBroadcast();
    }
}