// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "./ContentManager.sol";

contract BrandManager is Ownable {
    IERC20 public contentCreatorToken;
    ContentManager public contentManager;

    struct Brand {
        string name;
        string description;
        string logo;
        uint256 contentFeePerView;
        uint256 contentFeePerLike;
        uint256 contentFeePerComment;
    }

    mapping(address => Brand) public brands;

    constructor(address _contentCreatorToken, address _contentManager) {
        contentCreatorToken = IERC20(_contentCreatorToken);
        contentManager = ContentManager(_contentManager);
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
        contentManager.viewContent(_contentId);
        contentCreatorToken.transfer(
            contentManager.owner(_contentId),
            brands[msg.sender].contentFeePerView
        );
    }

    function sponsorLike(uint256 _contentId) public {
        require(
            brands[msg.sender].contentFeePerLike > 0,
            "Brand is not registered"
        );
        contentManager.likeContent(_contentId);
        contentCreatorToken.transfer(
            contentManager.owner(_contentId),
            brands[msg.sender].contentFeePerLike
        );
    }

    function sponsorComment(uint256 _contentId) public {
        require(
            brands[msg.sender].contentFeePerComment > 0,
            "Brand is not registered"
        );
        contentManager.commentContent(_contentId);
        contentCreatorToken.transfer(
            contentManager.owner(_contentId),
            brands[msg.sender].contentFeePerComment
        );
    }
}