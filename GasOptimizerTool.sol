// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GasOptimizerTool {
    uint256[100] private dataArray;
    mapping(address => uint256) private userData;

    event GasOptimizedOperation(address indexed user, uint256 value, uint256 gasUsed);

    function packData(uint32 a, uint32 b, uint32 c) external returns (uint256 packed) {
        assembly {
            packed := or(or(a, shl(32, b)), shl(64, c))
        }
    }

    function unpackData(uint256 packed) external pure returns (uint32 a, uint32 b, uint32 c) {
        a = uint32(packed);
        b = uint32(packed >> 32);
        c = uint32(packed >> 64);
    }

    function writeBatchStorage(uint256[] calldata indices, uint256[] calldata values) external {
        require(indices.length == values.length, "Mismatch");
        uint256 len = indices.length;
        for (uint256 i; i < len; i++) {
            dataArray[indices[i]] = values[i];
        }
    }

    function efficientWrite(address user, uint256 value) external {
        uint256 start = gasleft();
        userData[user] = value;
        emit GasOptimizedOperation(user, value, start - gasleft());
    }
}
