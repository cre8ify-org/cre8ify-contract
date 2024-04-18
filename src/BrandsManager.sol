// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
This contract allows brands to register their profiles on 
the platform and sponsor content by paying fees for views, likes, and comments. 
The fees are then transferred to the content creators, providing an additional revenue stream for them.
 */

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract BrandManager is Ownable {
    IERC20 public contentCreatorToken;

    struct Brand {
        string name;
        string description;
        string logo;
        uint256 contentFeePerView;
        uint256 contentFeePerLike;
        uint256 contentFeePerComment;
    }

    mapping(address => Brand) public brands;

    constructor(address _contentCreatorToken) {
        contentCreatorToken = IERC20(_contentCreatorToken);
    }

    function registerBrand(
        string memory _name,
        string memory _description,
        string memory _logo,
        uint256 _contentFeePerView,
        uint256 _contentFeePerLike,
        uint256 _contentFeePerComment
    ) public {
        require(bytes(_name).length > 0, "Brand name cannot be empty");
        require(
            contentCreatorToken.balanceOf(msg.sender) >= 1000 * 10 ** 18,
            "Insufficient token balance"
        );
        contentCreatorToken.transferFrom(
            msg.sender,
            address(this),
            1000 * 10 ** 18
        );

        Brand storage newBrand = brands[msg.sender];
        newBrand.name = _name;
        newBrand.description = _description;
        newBrand.logo = _logo;
        newBrand.contentFeePerView = _contentFeePerView;
        newBrand.contentFeePerLike = _contentFeePerLike;
        newBrand.contentFeePerComment = _contentFeePerComment;
    }

    function sponsorContent(uint256 _contentId) public {
        require(
            brands[msg.sender].contentFeePerView > 0,
            "Brand is not registered"
        );
        ContentManager(msg.sender).viewContent(_contentId);
        contentCreatorToken.transfer(
            ContentManager(msg.sender).owner(_contentId),
            brands[msg.sender].contentFeePerView
        );
    }

    function sponsorLike(uint256 _contentId) public {
        require(
            brands[msg.sender].contentFeePerLike > 0,
            "Brand is not registered"
        );
        ContentManager(msg.sender).likeContent(_contentId);
        contentCreatorToken.transfer(
            ContentManager(msg.sender).owner(_contentId),
            brands[msg.sender].contentFeePerLike
        );
    }

    function sponsorComment(uint256 _contentId) public {
        require(
            brands[msg.sender].contentFeePerComment > 0,
            "Brand is not registered"
        );
        ContentManager(msg.sender).commentContent(_contentId);
        contentCreatorToken.transfer(
            ContentManager(msg.sender).owner(_contentId),
            brands[msg.sender].contentFeePerComment
        );
    }
}
