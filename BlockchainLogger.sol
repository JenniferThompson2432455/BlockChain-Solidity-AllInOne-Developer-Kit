// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BlockchainLogger is Ownable {
    struct Log {
        address operator;
        string action;
        uint256 timestamp;
        bytes32 dataHash;
    }

    Log[] public logs;

    event LogRecorded(address indexed operator, string action, uint256 time, bytes32 data);

    constructor() Ownable(msg.sender) {}

    function recordLog(string calldata action, bytes32 dataHash) external onlyOwner {
        logs.push(Log({
            operator: msg.sender,
            action: action,
            timestamp: block.timestamp,
            dataHash: dataHash
        }));
        emit LogRecorded(msg.sender, action, block.timestamp, dataHash);
    }

    function getLogCount() external view returns (uint256) {
        return logs.length;
    }

    function getLogs(uint256 start, uint256 end) external view returns (Log[] memory) {
        require(end > start && end <= logs.length, "Invalid range");
        uint256 len = end - start;
        Log[] memory result = new Log[](len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = logs[start + i];
        }
        return result;
    }
}
