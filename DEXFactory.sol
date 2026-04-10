// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract DEXFactory is Ownable {
    mapping(address => mapping(address => address)) public pairs;
    address[] public allPairs;

    event PairCreated(address indexed tokenA, address indexed tokenB, address pair, uint256 index);

    constructor() Ownable(msg.sender) {}

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "Identical");
        require(pairs[tokenA][tokenB] == address(0), "Exists");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        bytes memory bytecode = type(Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        pairs[tokenA][tokenB] = pair;
        pairs[tokenB][tokenA] = pair;
        allPairs.push(pair);
        emit PairCreated(tokenA, tokenB, pair, allPairs.length);
    }
}

contract Pair {
    address public factory;
    address public token0;
    address public token1;

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "Only factory");
        token0 = _token0;
        token1 = _token1;
    }
}
