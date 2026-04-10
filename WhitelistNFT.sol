// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WhitelistNFT is ERC721, Ownable {
    uint256 public tokenId;
    string public baseURI;
    uint256 public publicPrice = 0.002 ether;
    uint256 public whitelistPrice = 0.001 ether;
    uint256 public maxPerWallet = 5;
    bool public whitelistActive;
    bool public publicActive;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) public mintedCount;

    constructor(string memory name, string memory symbol, string memory uri) 
        ERC721(name, symbol) 
        Ownable(msg.sender) 
    {
        baseURI = uri;
    }

    function addToWhitelist(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelist[users[i]] = true;
        }
    }

    function toggleWhitelist(bool status) external onlyOwner {
        whitelistActive = status;
    }

    function togglePublic(bool status) external onlyOwner {
        publicActive = status;
    }

    function whitelistMint() external payable {
        require(whitelistActive && whitelist[msg.sender], "Not allowed");
        require(mintedCount[msg.sender] < maxPerWallet, "Limit reached");
        require(msg.value >= whitelistPrice, "Insufficient");
        _safeMint(msg.sender, tokenId);
        tokenId++;
        mintedCount[msg.sender]++;
    }

    function publicMint() external payable {
        require(publicActive, "Not active");
        require(mintedCount[msg.sender] < maxPerWallet, "Limit reached");
        require(msg.value >= publicPrice, "Insufficient");
        _safeMint(msg.sender, tokenId);
        tokenId++;
        mintedCount[msg.sender]++;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
