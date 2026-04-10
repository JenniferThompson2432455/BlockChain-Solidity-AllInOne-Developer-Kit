// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract OraclePriceFeed is Ownable {
    address public oracleOperator;
    mapping(bytes32 => uint256) public priceData;
    mapping(bytes32 => uint256) public lastUpdateTime;

    event PriceUpdated(bytes32 indexed pair, uint256 price, uint256 timestamp);

    constructor() Ownable(msg.sender) {
        oracleOperator = msg.sender;
    }

    modifier onlyOperator() {
        require(msg.sender == oracleOperator, "Not operator");
        _;
    }

    function setOperator(address op) external onlyOwner {
        oracleOperator = op;
    }

    function updatePrice(bytes32 pair, uint256 price) external onlyOperator {
        require(price > 0, "Invalid price");
        priceData[pair] = price;
        lastUpdateTime[pair] = block.timestamp;
        emit PriceUpdated(pair, price, block.timestamp);
    }

    function getPrice(bytes32 pair) external view returns (uint256, uint256) {
        return (priceData[pair], lastUpdateTime[pair]);
    }

    function isPriceValid(bytes32 pair, uint256 maxAge) external view returns (bool) {
        return block.timestamp - lastUpdateTime[pair] <= maxAge;
    }
}
