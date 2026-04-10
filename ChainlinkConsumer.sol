// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChainlinkConsumer is Ownable {
    mapping(address => AggregatorV3Interface) public priceFeeds;
    mapping(address => uint8) public feedDecimals;

    constructor() Ownable(msg.sender) {}

    function addPriceFeed(address token, address feed) external onlyOwner {
        AggregatorV3Interface oracle = AggregatorV3Interface(feed);
        priceFeeds[token] = oracle;
        feedDecimals[token] = oracle.decimals();
    }

    function getLatestPrice(address token) external view returns (uint256, uint256) {
        AggregatorV3Interface feed = priceFeeds[token];
        require(address(feed) != address(0), "Feed not set");
        (, int256 price,, uint256 timestamp,) = feed.latestRoundData();
        require(price > 0, "Invalid price");
        return (uint256(price), timestamp);
    }

    function getNormalizedPrice(address token) external view returns (uint256) {
        (uint256 price,) = getLatestPrice(token);
        uint8 dec = feedDecimals[token];
        return price * (10 ** (18 - dec));
    }
}
