// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DynamicNFT is ERC721, Ownable {
    uint256 public tokenId;
    string public baseURI;
    mapping(uint256 => uint256) public tokenLevel;

    constructor(string memory name, string memory symbol, string memory uri) 
        ERC721(name, symbol) 
        Ownable(msg.sender) 
    {
        baseURI = uri;
    }

    function mint() external {
        _safeMint(msg.sender, tokenId);
        tokenLevel[tokenId] = 1;
        tokenId++;
    }

    function levelUp(uint256 id) external {
        require(ownerOf(id) == msg.sender, "Not owner");
        tokenLevel[id]++;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, "/", id, "/", tokenLevel[id]));
    }
}
