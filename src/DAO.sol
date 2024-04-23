// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Authorization.sol";
import "./Content.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO is Ownable, Authorization {
    struct Proposal {
        uint256 id;
        string description;
        address creator;
        bool executed;
        uint256 yesVotes;
        bool isExecuted;
        uint256 startTimestamp;
        uint256 noVotes;
        uint256 expirationTime;
        uint256 endTimestamp;
        bool isMonetized; // Add this line
    }

    enum ProposalType { ContentModeration, UserModeration, TreasuryManagement, ParameterChange }

    mapping(uint256 => Proposal) public proposals;
    mapping (uint256 => mapping(address => bool)) hasVoted;

    uint256 public proposalCount;
    uint256 public quorum;
    uint256 public minVotesRequired;
    uint256 public proposalDuration;
    
    Content public contentContract;
    IERC20 public token;

    constructor(address _contentContract, address _tokenAddress) {
        contentContract = Content(_contentContract);
        token = IERC20(_tokenAddress);
        quorum = 20; 
        minVotesRequired = 5; 
        proposalDuration = 7 days;
    }
    event ProposalSubmitted(uint256 id, string description, address creator, ProposalType proposalType);
    event Voted(uint256 id, address voter);
    event ProposalExecuted(uint256 id, ProposalType proposalType, bool executed);
    event ContentModerated(uint256 id, address moderator);
    event UserModerated(address indexed user, bool banned);
    event TreasuryManaged(address indexed beneficiary, uint256 amount);
    event ParameterChanged(string parameter, uint256 newValue);

    // Submit proposal for DAO consideration
    function submitProposal(string memory _description, ProposalType _proposalType) public onlyRegistered {
        require(_proposalType != ProposalType.ParameterChange, "Invalid proposal type");
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            creator: msg.sender,
            executed: false,
            yesVotes: 0,
            noVotes: 0,
            expirationTime: block.timestamp + proposalDuration
        });

        emit ProposalSubmitted(proposalCount, _description, msg.sender, _proposalType);
    }

    // Vote on proposal
    function vote(uint256 _proposalId, bool _vote) public onlyRegistered {
        Proposal storage proposal = proposals[_proposalId];
        require(hasVoted[_proposalId][msg.sender], "Already voted");
        require(!proposal.executed, "Proposal has been executed");
        require(block.timestamp < proposal.expirationTime, "Proposal has expired");

        if (_vote) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }

        hasVoted[_proposalId][msg.sender] = true;
        emit Voted(_proposalId, msg.sender);
    }

    // Execute approved proposal
    function executeProposal(uint256 _proposalId, ProposalType _proposalType) public onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal has been executed");
        require(block.timestamp >= proposal.expirationTime, "Proposal has not expired yet");

        uint256 totalVotes = proposal.yesVotes + proposal.noVotes;
        require((proposal.yesVotes * 100) >= (totalVotes * quorum), "Quorum not met");
        require(proposal.yesVotes >= minVotesRequired, "Minimum votes not met");

        proposal.executed = true;

        if (_proposalType == ProposalType.ContentModeration) {
            contentContract.deleteContent(_proposalId);
        } else if (_proposalType == ProposalType.UserModeration) {
            emit UserModerated(proposals[_proposalId].creator, true);
        } else if (_proposalType == ProposalType.TreasuryManagement) {
            uint256 amount = token.balanceOf(address(this));
            token.transfer(owner(), amount);
            emit TreasuryManaged(owner(), amount);
        }

        emit ProposalExecuted(_proposalId, _proposalType, true);
    }

    // Change governance parameters
    function changeParameter(string memory _parameter, uint256 _newValue) public onlyOwner {
        if (keccak256(abi.encodePacked(_parameter)) == keccak256(abi.encodePacked("quorum"))) {
            quorum = _newValue;
        } else if (keccak256(abi.encodePacked(_parameter)) == keccak256(abi.encodePacked("minVotesRequired"))) {
            minVotesRequired = _newValue;
        } else if (keccak256(abi.encodePacked(_parameter)) == keccak256(abi.encodePacked("proposalDuration"))) {
            proposalDuration = _newValue;
        }

        emit ParameterChanged(_parameter, _newValue);
    }

    // Content moderation (only owner can moderate)
    function moderateContent(uint256 _contentId) public onlyOwner {
        contentContract.deleteContent(_contentId);
        emit ContentModerated(_contentId, msg.sender);
    }

    // User moderation (ban/unban user)
    function moderateUser(address _userAddress, bool _ban) public onlyOwner {
        emit UserModerated(_userAddress, _ban);
    }

    // Treasury management
    function manageTreasury() public onlyOwner {
        uint256 amount = token.balanceOf(address(this));
        token.transfer(owner(), amount);
        emit TreasuryManaged(owner(), amount);
    }

    // Other governance functions
    function changeOwner(address _newOwner) public onlyOwner {
        transferOwnership(_newOwner);
    }

    function emergencyWithdrawTokens(address _tokenAddress, address _to, uint256 _amount) public onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        token.transfer(_to, _amount);
    }

    function withdrawEther(address payable _to, uint256 _amount) public onlyOwner {
        require(address(this).balance >= _amount, "Insufficient ETH balance");
        _to.transfer(_amount);
    }

    // Fallback function to receive ETH
    receive() external payable {}

function getYesVotes(uint256 proposalId) public view returns (uint256) {
    return proposals[proposalId].yesVotes;
}
function isProposalExecuted(uint256 proposalId) public view returns (bool) {
    return proposals[proposalId].isExecuted;
}
}
