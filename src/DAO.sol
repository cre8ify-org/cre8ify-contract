// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CCP.sol";

contract ContentDAO {
    CCP public ccpContract;
    mapping(address => bool) public members;
    address[] public initialMembers;
    uint256 public numProposals;

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCountYes;
        uint256 voteCountNo;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 id, string description);
    event VoteCast(uint256 proposalId, bool inFavor, address voter);
    event ProposalExecuted(uint256 id);

    modifier onlyMembers() {
        require(members[msg.sender], "Only members can perform this action");
        _;
    }

    constructor(address _ccpContract) {
        ccpContract = CCP(_ccpContract);

        // Add initial members
        initialMembers = [
            0x8d3d5f52F2548DBB43F03E8e1352733Ba56c05eB,
            0xA59d8308408dF2B774471e43C3b0C2b4F0D1e482
        ];

        for (uint256 i = 0; i < initialMembers.length; i++) {
            members[initialMembers[i]] = true;
        }
    }

    function addMember(address member) public onlyMembers {
        members[member] = true;
    }

    function removeMember(address member) public onlyMembers {
        members[member] = false;
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

        if (inFavor) {
            proposal.voteCountYes++;
        } else {
            proposal.voteCountNo++;
        }

        emit VoteCast(proposalId, inFavor, msg.sender);
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
        }

        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }
}