// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMinterFactory is ERC721, Ownable {
    uint256 public tokenCounter;
    string public baseURI;
    uint256 public mintPrice = 0.001 ether;
    uint256 public maxSupply = 10000;

    constructor(string memory name, string memory symbol, string memory uri) 
        ERC721(name, symbol) 
        Ownable(msg.sender) 
    {
        baseURI = uri;
    }

    function mint() external payable {
        require(tokenCounter < maxSupply, "Max supply");
        require(msg.value >= mintPrice, "Insufficient payment");
        _safeMint(msg.sender, tokenCounter);
        tokenCounter++;
    }

    function adminMint(address to, uint256 amount) external onlyOwner {
        require(tokenCounter + amount <= maxSupply, "Exceed supply");
        for (uint256 i = 0; i < amount; i++) {
            _safeMint(to, tokenCounter);
            tokenCounter++;
        }
    }

    function setBaseURI(string calldata uri) external onlyOwner {
        baseURI = uri;
    }

    function setMintPrice(uint256 price) external onlyOwner {
        mintPrice = price;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
