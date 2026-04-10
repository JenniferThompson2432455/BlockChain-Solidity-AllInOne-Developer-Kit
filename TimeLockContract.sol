// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TimeLockContract is Ownable {
    uint256 public constant MIN_DELAY = 1 days;
    uint256 public constant MAX_DELAY = 30 days;

    mapping(bytes32 => uint256) public executeTime;

    event TransactionQueued(bytes32 indexed txId, uint256 execTime);
    event TransactionExecuted(bytes32 indexed txId);

    constructor() Ownable(msg.sender) {}

    function hashTx(address target, uint256 value, string calldata func, bytes calldata data, uint256 delay) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, func, data, delay));
    }

    function queueTransaction(address target, uint256 value, string calldata func, bytes calldata data, uint256 delay) external onlyOwner {
        require(delay >= MIN_DELAY && delay <= MAX_DELAY, "Invalid delay");
        bytes32 txId = hashTx(target, value, func, data, delay);
        executeTime[txId] = block.timestamp + delay;
        emit TransactionQueued(txId, block.timestamp + delay);
    }

    function executeTransaction(address target, uint256 value, string calldata func, bytes calldata data, uint256 delay) external payable onlyOwner {
        bytes32 txId = hashTx(target, value, func, data, delay);
        require(block.timestamp >= executeTime[txId], "Too early");
        executeTime[txId] = 0;
        (bool success,) = target.call{value: value}(abi.encodeWithSignature(func, data));
        require(success, "Execution failed");
        emit TransactionExecuted(txId);
    }
}
