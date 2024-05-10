// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CCP.sol";
import "./Token.sol";
import "./Vault.sol";
contract ContentDAO {
    CCP public ccpContract;
    Token public tokenContract;
    Vault public vaultContract;

    mapping(address => uint256) public stakedTokens;
    mapping(address => bool) public members;
    uint256 public minimumStake;
    uint256 public memberCount;

    uint256 public numProposals;
    mapping(uint256 => Proposal) public proposals;

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCountYes;
        uint256 voteCountNo;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    event ProposalCreated(uint256 id, string description);
    event VoteCast(uint256 proposalId, bool inFavor, address voter, uint256 votingPower);
    event ProposalExecuted(uint256 id);
    event MemberJoined(address member, uint256 stakeAmount);
    event MemberLeft(address member, uint256 unstakeAmount);

    modifier onlyMembers() {
        require(members[msg.sender], "Only members can perform this action");
        _;
    }

   constructor(address _ccpContract, address _tokenContract, uint256 _minimumStake, address _vaultAddress) {
    ccpContract = CCP(_ccpContract);
    tokenContract = Token(_tokenContract);
    minimumStake = _minimumStake;
    vaultContract = Vault(_vaultAddress);
}

function joinDAO(uint256 stakeAmount) public {
    require(!members[msg.sender], "Already a member");
    require(stakeAmount >= minimumStake, "Stake amount too low");
    require(tokenContract.approve(address(vaultContract), stakeAmount), "Token approval failed");
    vaultContract.stake(stakeAmount, msg.sender);
    stakedTokens[msg.sender] = stakeAmount;
    members[msg.sender] = true;
    memberCount++;
    emit MemberJoined(msg.sender, stakeAmount);
}

 function leaveDAO() public onlyMembers {
    uint256 unstakeAmount = stakedTokens[msg.sender];
    require(unstakeAmount > 0, "No staked tokens");
    vaultContract.withdrawStake(unstakeAmount, msg.sender);
    stakedTokens[msg.sender] = 0;
    members[msg.sender] = false;
    memberCount--;
    emit MemberLeft(msg.sender, unstakeAmount);
}

    function createProposal(string memory description) public onlyMembers returns (uint256) {
        Proposal storage newProposal = proposals[numProposals];
        newProposal.id = numProposals;
        newProposal.description = description;
        newProposal.voteCountYes = 0;
        newProposal.voteCountNo = 0;
        newProposal.executed = false;
        emit ProposalCreated(numProposals, description);
        numProposals++;
        return numProposals - 1;
    }

    function voteProposal(uint256 proposalId, bool inFavor) public onlyMembers {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal has already been executed");
        require(!proposal.hasVoted[msg.sender], "Already voted");

        uint256 votingPower = stakedTokens[msg.sender];
        if (inFavor) {
            proposal.voteCountYes += votingPower;
        } else {
            proposal.voteCountNo += votingPower;
        }
        proposal.hasVoted[msg.sender] = true;

        emit VoteCast(proposalId, inFavor, msg.sender, votingPower);
    }

    function executeProposal(uint256 proposalId) public onlyMembers {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal has already been executed");
        require(proposal.voteCountYes > proposal.voteCountNo, "Proposal did not pass");

        // Execute proposal logic here
        string memory description = proposal.description;
        if (keccak256(bytes(description)) == keccak256(bytes("Change user state variables"))) {
            // Modify user state variables
            // Example: ccpContract.updateUserVariables(address, ...);
        } else if (keccak256(bytes(description)) == keccak256(bytes("Delete content"))) {
            // Delete content
            // Example: ccpContract.deleteContent(uint256);
        } else if (keccak256(bytes(description)) == keccak256(bytes("Ban user"))) {
            // Ban user
            // Example: ccpContract.banUser(address);
        } else if (keccak256(bytes(description)) == keccak256(bytes("Unban user"))) {
            // Unban user
            // Example: ccpContract.unbanUser(address);
        } else if (keccak256(bytes(description)) == keccak256(bytes("Update minimum stake"))) {
            // Update minimum stake
            updateMinimumStake(parseStakeAmount(description));
        }

        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }

    function updateMinimumStake(uint256 newStake) private {
        minimumStake = newStake;
    }

    function parseStakeAmount(string memory description) private pure returns (uint256) {
        // Implement logic to parse the stake amount from the description string
        // Return the parsed stake amount
    }
}