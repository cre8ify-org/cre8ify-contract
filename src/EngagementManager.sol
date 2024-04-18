// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
This contract handles the engagement features of the platform, 
including polls and live streams. Users can create polls and vote on them by spending platform tokens. 
They can also start live streams and join other users' live streams, with the content creator receiving tokens for each viewer. */

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract EngagementManager is Ownable {
    IERC20 public contentCreatorToken;

    struct Poll {
        string question;
        mapping(string => uint256) options;
        uint256 startTime;
        uint256 endTime;
    }

    struct LiveStream {
        string streamId;
        uint256 startTime;
        uint256 endTime;
        uint256 viewers;
    }

    mapping(uint256 => Poll) public polls;
    mapping(uint256 => LiveStream) public liveStreams;
    uint256 public pollCount;
    uint256 public liveStreamCount;

    constructor(address _contentCreatorToken) {
        contentCreatorToken = IERC20(_contentCreatorToken);
    }

    function createPoll(
        string memory _question,
        string[] memory _options,
        uint256 _duration
    ) public {
        require(contentCreatorToken.balanceOf(msg.sender) >= 100 * 10 ** 18, "Insufficient token balance");
        Poll storage newPoll = polls[pollCount];
        newPoll.question = _question;
        newPoll.startTime = block.timestamp;
        newPoll.endTime = block.timestamp + _duration;

        for (uint256 i = 0; i < _options.length; i++) {
            newPoll.options[_options[i]] = 0;
        }

        pollCount++;
        contentCreatorToken.transferFrom(msg.sender, address(this), 100 * 10 ** 18);
    }

    function votePoll(uint256 _pollId, string memory _option) public {
        require(block.timestamp >= polls[_pollId].startTime && block.timestamp <= polls[_pollId].endTime, "Poll is not active");
        require(contentCreatorToken.balanceOf(msg.sender) >= 10 * 10 ** 18, "Insufficient token balance");
        polls[_pollId].options[_option]++;
        contentCreatorToken.transferFrom(msg.sender, address(this), 10 * 10 ** 18);
    }

    function startLiveStream(string memory _streamId) public {
        require(contentCreatorToken.balanceOf(msg.sender) >= 1000 * 10 ** 18, "Insufficient token balance");
        LiveStream storage newStream = liveStreams[liveStreamCount];
        newStream.streamId = _streamId;
        newStream.startTime = block.timestamp;
        newStream.viewers = 0;
        liveStreamCount++;
        contentCreatorToken.transferFrom(msg.sender, address(this), 1000 * 10 ** 18);
    }

    function joinLiveStream(uint256 _streamId) public {
        require(block.timestamp >= liveStreams[_streamId].startTime, "Live stream has not started");
        require(contentCreatorToken.balanceOf(msg.sender) >= 10 * 10 ** 18, "Insufficient token balance");
        liveStreams[_streamId].viewers++;
        contentCreatorToken.transferFrom(msg.sender, address(this), 10 * 10 ** 18);
    }
}