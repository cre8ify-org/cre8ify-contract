// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title PlatformTreasury
 * @dev Manages platform fees distribution among team members using a multi-signature approach
 */
contract PlatformTreasury {
    address[] public teamMembers;
    uint256 public requiredSignatures;
    mapping(bytes32 => mapping(address => bool)) public confirmations;

    struct Withdrawal {
        address token;
        address payable recipient;
        uint256 amount;
        bool executed;
    }

    mapping(bytes32 => Withdrawal) public withdrawals;
    bytes32[] public withdrawalIds;

    event WithdrawalProposed(
        bytes32 withdrawalId,
        address proposer,
        address token,
        address recipient,
        uint256 amount
    );
    event WithdrawalConfirmed(bytes32 withdrawalId, address confirmer);
    event WithdrawalExecuted(bytes32 withdrawalId, address executor);
    event FundsReceived(address sender, uint256 amount);
    event PlatformFeesWithdrawn(address vaultAddress, uint256 amount);

    /**
     * @dev Constructor to initialize the treasury with team members and required signatures
     * @param _teamMembers Array of team member addresses
     * @param _requiredSignatures Number of signatures required to execute a withdrawal
     */
    constructor(address[] memory _teamMembers, uint256 _requiredSignatures) {
        require(_teamMembers.length > 0, "Team members required");
        require(
            _requiredSignatures > 0 &&
                _requiredSignatures <= _teamMembers.length,
            "Invalid signature requirement"
        );

        teamMembers = _teamMembers;
        requiredSignatures = _requiredSignatures;
    }

    /**
     * @dev Modifier to restrict functions to team members only
     */
    modifier onlyTeamMember() {
        bool isMember = false;
        for (uint i = 0; i < teamMembers.length; i++) {
            if (msg.sender == teamMembers[i]) {
                isMember = true;
                break;
            }
        }
        require(isMember, "Not a team member");
        _;
    }

    /**
     * @dev Propose a withdrawal of native tokens (ETH/LSK)
     * @param _recipient Address to receive the funds
     * @param _amount Amount to withdraw
     * @return withdrawalId Unique identifier for the withdrawal
     */
    function proposeNativeWithdrawal(
        address payable _recipient,
        uint256 _amount
    ) public onlyTeamMember returns (bytes32) {
        require(_amount <= address(this).balance, "Insufficient balance");

        bytes32 withdrawalId = keccak256(
            abi.encodePacked(block.timestamp, address(0), _recipient, _amount)
        );

        withdrawals[withdrawalId] = Withdrawal({
            token: address(0), // 0 address indicates native token
            recipient: _recipient,
            amount: _amount,
            executed: false
        });

        withdrawalIds.push(withdrawalId);
        confirmations[withdrawalId][msg.sender] = true;

        emit WithdrawalProposed(
            withdrawalId,
            msg.sender,
            address(0),
            _recipient,
            _amount
        );

        return withdrawalId;
    }

    /**
     * @dev Propose a withdrawal of ERC20 tokens
     * @param _token Address of the ERC20 token
     * @param _recipient Address to receive the tokens
     * @param _amount Amount of tokens to withdraw
     * @return withdrawalId Unique identifier for the withdrawal
     */
    function proposeTokenWithdrawal(
        address _token,
        address payable _recipient,
        uint256 _amount
    ) public onlyTeamMember returns (bytes32) {
        require(_token != address(0), "Invalid token address");
        require(
            _amount <= IERC20(_token).balanceOf(address(this)),
            "Insufficient token balance"
        );

        bytes32 withdrawalId = keccak256(
            abi.encodePacked(block.timestamp, _token, _recipient, _amount)
        );

        withdrawals[withdrawalId] = Withdrawal({
            token: _token,
            recipient: _recipient,
            amount: _amount,
            executed: false
        });

        withdrawalIds.push(withdrawalId);
        confirmations[withdrawalId][msg.sender] = true;

        emit WithdrawalProposed(
            withdrawalId,
            msg.sender,
            _token,
            _recipient,
            _amount
        );

        return withdrawalId;
    }

    /**
     * @dev Confirm a withdrawal proposal
     * @param _withdrawalId ID of the withdrawal to confirm
     */
    function confirmWithdrawal(bytes32 _withdrawalId) public onlyTeamMember {
        require(!confirmations[_withdrawalId][msg.sender], "Already confirmed");
        require(!withdrawals[_withdrawalId].executed, "Already executed");

        confirmations[_withdrawalId][msg.sender] = true;
        emit WithdrawalConfirmed(_withdrawalId, msg.sender);

        executeWithdrawalIfConfirmed(_withdrawalId);
    }

    /**
     * @dev Execute a withdrawal if it has enough confirmations
     * @param _withdrawalId ID of the withdrawal to execute
     */
    function executeWithdrawalIfConfirmed(bytes32 _withdrawalId) internal {
        if (isConfirmed(_withdrawalId)) {
            Withdrawal storage withdrawal = withdrawals[_withdrawalId];
            require(!withdrawal.executed, "Already executed");

            withdrawal.executed = true;

            if (withdrawal.token == address(0)) {
                // Native token transfer
                (bool success, ) = withdrawal.recipient.call{
                    value: withdrawal.amount
                }("");
                require(success, "Native transfer failed");
            } else {
                // ERC20 token transfer
                bool success = IERC20(withdrawal.token).transfer(
                    withdrawal.recipient,
                    withdrawal.amount
                );
                require(success, "Token transfer failed");
            }

            emit WithdrawalExecuted(_withdrawalId, msg.sender);
        }
    }

    /**
     * @dev Check if a withdrawal has enough confirmations
     * @param _withdrawalId ID of the withdrawal to check
     * @return Whether the withdrawal is confirmed
     */
    function isConfirmed(bytes32 _withdrawalId) public view returns (bool) {
        uint count = 0;
        for (uint i = 0; i < teamMembers.length; i++) {
            if (confirmations[_withdrawalId][teamMembers[i]]) count++;
            if (count >= requiredSignatures) return true;
        }
        return false;
    }

    /**
     * @dev Get all withdrawal IDs
     * @return Array of withdrawal IDs
     */
    function getWithdrawalIds() external view returns (bytes32[] memory) {
        return withdrawalIds;
    }

    /**
     * @dev Get all team members
     * @return Array of team member addresses
     */
    function getTeamMembers() external view returns (address[] memory) {
        return teamMembers;
    }

    /**
     * @dev Withdraw platform fees from the Vault contract
     * @param _vaultAddress Address of the Vault contract
     * @param _amount Amount to withdraw
     */
    function withdrawPlatformFees(
        address _vaultAddress,
        uint256 _amount
    ) external onlyTeamMember {
        // This function would be called after a withdrawal proposal is approved
        // It interacts with your Vault contract to withdraw the platform fees
        bytes4 selector = bytes4(keccak256("withdrawPlatformFees(uint256)"));
        (bool success, ) = _vaultAddress.call(
            abi.encodeWithSelector(selector, _amount)
        );
        require(success, "Vault withdrawal failed");

        emit PlatformFeesWithdrawn(_vaultAddress, _amount);
    }

    /**
     * @dev Receive function to accept native tokens
     */
    receive() external payable {
        emit FundsReceived(msg.sender, msg.value);
    }
}
