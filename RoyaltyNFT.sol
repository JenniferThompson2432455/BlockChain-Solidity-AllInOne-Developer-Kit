// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RoyaltyNFT is ERC721, Ownable {
    uint256 public tokenId;
    string public baseURI;
    uint256 public mintPrice = 0.0015 ether;
    uint256 public royaltyFee = 500;

    constructor(string memory name, string memory symbol, string memory uri) 
        ERC721(name, symbol) 
        Ownable(msg.sender) 
    {
        baseURI = uri;
    }

    function mint() external payable {
        require(msg.value >= mintPrice, "Insufficient");
        _safeMint(msg.sender, tokenId);
        tokenId++;
    }

    function royaltyInfo(uint256, uint256 salePrice) external view returns (address, uint256) {
        uint256 royalty = (salePrice * royaltyFee) / 10000;
        return (owner(), royalty);
    }

    function setRoyaltyFee(uint256 fee) external onlyOwner {
        require(fee <= 1000, "Max 10%");
        royaltyFee = fee;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
