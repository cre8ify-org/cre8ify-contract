// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./ContentManager.sol";
import "./ContentCreatorToken.sol";

contract RewardManager is Ownable {
    IERC20 public contentCreatorToken;
    ContentManager public contentManager;

    struct Reward {
        uint256 contentId;
        address user;
        uint256 amount;
        uint256 distributedAt;
    }

    mapping(uint256 => Reward[]) public contentRewards;
    mapping(address => uint256) public userClaimableRewards;

    constructor(address _contentCreatorToken, address _contentManager) {
        contentCreatorToken = IERC20(_contentCreatorToken);
        contentManager = ContentManager(_contentManager);
    }

    function distributeRewards(uint256 _contentId, address[] memory _users, uint256[] memory _amounts) public {
        ContentManager.Content storage content = contentManager.userContent(msg.sender, _contentId);
        require(content.views >= 1000, "Content must have at least 1000 views");
        require(content.likes >= 100, "Content must have at least 100 likes");
        require(content.comments >= 50, "Content must have at least 50 comments");
        require(_users.length == _amounts.length, "Users and amounts arrays must have the same length");

        uint256 totalRewards = _calculateTotalRewards(_amounts);
        contentCreatorToken.transferFrom(msg.sender, address(this), totalRewards);

        for (uint256 i = 0; i < _users.length; i++) {
            Reward memory newReward = Reward({
                contentId: _contentId,
                user: _users[i],
                amount: _amounts[i],
                distributedAt: block.timestamp
            });
            contentRewards[_contentId].push(newReward);
            userClaimableRewards[_users[i]] += _amounts[i];
        }
    }

    function claimRewards() public {
        uint256 claimableRewards = userClaimableRewards[msg.sender];
        require(claimableRewards > 0, "No rewards to claim");
        userClaimableRewards[msg.sender] = 0;
        contentCreatorToken.transfer(msg.sender, claimableRewards);
    }

    function _calculateTotalRewards(uint256[] memory _amounts) internal pure returns (uint256) {
        uint256 totalRewards = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            totalRewards += _amounts[i];
        }
        return totalRewards;
    }
}