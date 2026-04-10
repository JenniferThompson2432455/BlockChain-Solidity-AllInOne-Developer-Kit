// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SecureWalletManager is Ownable {
    mapping(address => bool) public authorizedContracts;

    event FundsWithdrawn(address indexed token, address indexed to, uint256 amount);
    event NFTWithdrawn(address indexed contractAddr, uint256 indexed tokenId, address indexed to);

    constructor() Ownable(msg.sender) {}

    function authorizeContract(address addr, bool status) external onlyOwner {
        authorizedContracts[addr] = status;
    }

    function withdrawNative(address to, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(to).transfer(amount);
    }

    function withdrawERC20(address token, address to, uint256 amount) external onlyOwner {
        require(authorizedContracts[token], "Unauthorized token");
        IERC20(token).transfer(to, amount);
        emit FundsWithdrawn(token, to, amount);
    }

    function withdrawERC721(address nftAddr, uint256 tokenId, address to) external onlyOwner {
        require(authorizedContracts[nftAddr], "Unauthorized NFT");
        IERC721(nftAddr).transferFrom(address(this), to, tokenId);
        emit NFTWithdrawn(nftAddr, tokenId, to);
    }

    receive() external payable {}
}
