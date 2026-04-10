// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrossChainBridge is Ownable {
    mapping(address => bool) public supportedTokens;
    mapping(uint256 => bool) public processedNonces;
    address public bridgeValidator;

    event TokenLocked(address indexed token, address indexed user, uint256 amount, uint256 chainId, uint256 nonce);
    event TokenUnlocked(address indexed token, address indexed user, uint256 amount);

    constructor() Ownable(msg.sender) {
        bridgeValidator = msg.sender;
    }

    function setValidator(address validator) external onlyOwner {
        bridgeValidator = validator;
    }

    function addSupportToken(address token) external onlyOwner {
        supportedTokens[token] = true;
    }

    function lockTokens(address token, uint256 amount, uint256 targetChain, uint256 nonce) external {
        require(supportedTokens[token], "Token not supported");
        require(!processedNonces[nonce], "Nonce used");
        require(amount > 0, "Invalid amount");

        processedNonces[nonce] = true;
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit TokenLocked(token, msg.sender, amount, targetChain, nonce);
    }

    function unlockTokens(address token, address to, uint256 amount, uint256 nonce) external {
        require(msg.sender == bridgeValidator, "Not validator");
        require(!processedNonces[nonce], "Nonce used");
        require(supportedTokens[token], "Token not supported");

        processedNonces[nonce] = true;
        IERC20(token).transfer(to, amount);
        emit TokenUnlocked(token, to, amount);
    }
}
