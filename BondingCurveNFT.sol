// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BondingCurveNFT is ERC721, Ownable {
    uint256 public tokenId;
    uint256 public basePrice = 0.0005 ether;
    uint256 public priceIncrement = 0.0001 ether;

    constructor() ERC721("Bonding Curve NFT", "BCN") Ownable(msg.sender) {}

    function getCurrentPrice() public view returns (uint256) {
        return basePrice + (tokenId * priceIncrement);
    }

    function mint() external payable {
        uint256 price = getCurrentPrice();
        require(msg.value >= price, "Insufficient payment");
        _safeMint(msg.sender, tokenId);
        tokenId++;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}
