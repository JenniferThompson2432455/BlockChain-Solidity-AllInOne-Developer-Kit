// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SocialRecoveryWallet is Ownable {
    address public ownerWallet;
    address[] public guardians;
    uint256 public requiredApprovals;
    mapping(address => bool) public isGuardian;
    mapping(address => mapping(address => bool)) public recoveryVotes;

    event RecoveryInitiated(address indexed newOwner);
    event RecoveryApproved(address indexed guardian, address newOwner);

    constructor(address[] memory _guardians, uint256 required) Ownable(msg.sender) {
        require(required > 0 && required <= _guardians.length, "Invalid required");
        ownerWallet = msg.sender;
        requiredApprovals = required;
        for (uint256 i = 0; i < _guardians.length; i++) {
            isGuardian[_guardians[i]] = true;
            guardians.push(_guardians[i]);
        }
    }

    function initiateRecovery(address newOwner) external {
        require(isGuardian[msg.sender], "Not guardian");
        recoveryVotes[newOwner][msg.sender] = true;
        emit RecoveryApproved(msg.sender, newOwner);
        _checkRecovery(newOwner);
    }

    function _checkRecovery(address newOwner) internal {
        uint256 count;
        for (uint256 i = 0; i < guardians.length; i++) {
            if (recoveryVotes[newOwner][guardians[i]]) count++;
        }
        if (count >= requiredApprovals) {
            ownerWallet = newOwner;
        }
    }

    function isRecoveryComplete(address newOwner) external view returns (bool) {
        uint256 count;
        for (uint256 i = 0; i < guardians.length; i++) {
            if (recoveryVotes[newOwner][guardians[i]]) count++;
        }
        return count >= requiredApprovals;
    }
}
