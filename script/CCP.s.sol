// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import {Analytics} from "../src/Analytics.sol";
import {Authorization} from "../src/Authorization.sol";
import {Token} from "../src/Token.sol";
import {Subscription} from "../src/Subscription.sol";
import {CCP} from "../src/CCP.sol";
import {Vault} from "../src/Vault.sol";
import {PlatformTreasury} from "../src/PlatformTreasury.sol";

contract DeployContentPlatform is Script {
    Analytics public analytics;
    Authorization public authorization;
    Token public token;
    Subscription public subscription;
    CCP public ccp;
    Vault public vault;
    PlatformTreasury public treasury;

    // Team member addresses for the platform treasury
    address[] public teamMembers;
    uint256 public requiredSignatures = 5; // 5 out of 8 signatures required

    function setUp() public {
        // Set up team members - replace with actual addresses
        teamMembers = new address[](8);
        teamMembers[0] = 0x1111111111111111111111111111111111111111; // Replace with actual address
        teamMembers[1] = 0x2222222222222222222222222222222222222222; // Replace with actual address
        teamMembers[2] = 0x3333333333333333333333333333333333333333; // Replace with actual address
        teamMembers[3] = 0x4444444444444444444444444444444444444444; // Replace with actual address
        teamMembers[4] = 0x5555555555555555555555555555555555555555; // Replace with actual address
        teamMembers[5] = 0x6666666666666666666666666666666666666666; // Replace with actual address
        teamMembers[6] = 0x7777777777777777777777777777777777777777; // Replace with actual address
        teamMembers[7] = 0x8888888888888888888888888888888888888888; // Replace with actual address
    }

    function run() public {
        uint256 privateKey;
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            privateKey = key;
            vm.startBroadcast(privateKey);
        } catch {
            // If PRIVATE_KEY is not found, use the default broadcast signer
            vm.startBroadcast();
        }

        // Step 1: Deploy the token
        console.log("Deploying Token...");
        token = new Token("ContentCP", "CCP");
        console.log("Token deployed at:", address(token));

        // Step 2: Deploy Authorization contract
        console.log("Deploying Authorization...");
        authorization = new Authorization();
        console.log("Authorization deployed at:", address(authorization));

        // Step 3: Deploy Vault contract
        console.log("Deploying Vault...");
        vault = new Vault(address(token));
        console.log("Vault deployed at:", address(vault));

        // Step 4: Deploy Analytics contract (with temporary address)
        console.log("Deploying Analytics...");
        analytics = new Analytics(address(0));
        console.log("Analytics deployed at:", address(analytics));

        // Step 5: Deploy Subscription contract
        console.log("Deploying Subscription...");
        subscription = new Subscription(
            address(token),
            address(vault),
            address(authorization)
        );
        console.log("Subscription deployed at:", address(subscription));

        // Step 6: Deploy CCP contract
        console.log("Deploying CCP...");
        ccp = new CCP(
            address(authorization),
            address(analytics),
            address(subscription)
        );
        console.log("CCP deployed at:", address(ccp));

        // Step 7: Deploy PlatformTreasury contract
        console.log("Deploying PlatformTreasury...");
        treasury = new PlatformTreasury(teamMembers, requiredSignatures);
        console.log("PlatformTreasury deployed at:", address(treasury));

        // Step 8: Set up contract connections
        console.log("Setting up contract connections...");

        // Update Analytics with CCP address
        analytics.changeCCPContract(address(ccp));
        console.log("Updated Analytics with CCP address");

        // Set Subscription contract in Vault
        vault.setSubscriptionContract(address(subscription));
        console.log("Set Subscription contract in Vault");

        // Set PlatformTreasury address in Vault
        vault.setPlatformTreasuryAddress(address(treasury));
        console.log("Set PlatformTreasury address in Vault");

        // Step 9: Mint initial tokens if needed
        // Uncomment and modify as needed
        // token.mint(msg.sender, 1000000 * 10**18); // Mint 1,000,000 tokens to deployer
        // console.log("Minted initial tokens to deployer");

        console.log("Deployment completed successfully!");
        vm.stopBroadcast();
    }
}
