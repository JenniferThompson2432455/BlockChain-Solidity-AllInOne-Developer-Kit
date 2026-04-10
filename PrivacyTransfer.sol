// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PrivacyTransfer is Ownable {
    mapping(bytes32 => bool) public usedCommitments;
    uint256 public fee = 0.0005 ether;

    event PrivateTransfer(bytes32 indexed commitment, uint256 amount);

    constructor() Ownable(msg.sender) {}

    function transferPrivate(bytes32 commitment) external payable {
        require(!usedCommitments[commitment], "Used");
        require(msg.value >= fee, "Insufficient fee");
        usedCommitments[commitment] = true;
        emit PrivateTransfer(commitment, msg.value - fee);
    }

    function withdrawFees() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setFee(uint256 newFee) external onlyOwner {
        fee = newFee;
    }
}
