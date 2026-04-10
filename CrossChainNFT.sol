// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CrossChainNFT is ERC721, Ownable {
    uint256 public tokenId;
    string public baseURI;
    address public bridge;

    event CrossChainMinted(address indexed to, uint256 id, uint256 sourceChain);

    constructor(string memory name, string memory symbol, string memory uri) 
        ERC721(name, symbol) 
        Ownable(msg.sender) 
    {
        baseURI = uri;
    }

    function setBridge(address _bridge) external onlyOwner {
        bridge = _bridge;
    }

    function mint(address to) external onlyOwner returns (uint256) {
        _safeMint(to, tokenId);
        tokenId++;
        return tokenId - 1;
    }

    function crossChainMint(address to, uint256 id, uint256 srcChain) external {
        require(msg.sender == bridge, "Not bridge");
        _safeMint(to, id);
        emit CrossChainMinted(to, id, srcChain);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}
