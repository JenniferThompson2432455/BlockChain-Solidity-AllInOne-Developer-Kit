// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20CustomToken is ERC20, Ownable {
    uint8 private _customDecimals;
    bool public transferRestriction;
    mapping(address => bool) public blacklist;

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 totalSupply
    ) ERC20(name, symbol) Ownable(msg.sender) {
        _customDecimals = decimals_;
        _mint(msg.sender, totalSupply * 10 ** decimals_);
    }

    function decimals() public view override returns (uint8) {
        return _customDecimals;
    }

    function setTransferRestriction(bool status) external onlyOwner {
        transferRestriction = status;
    }

    function setBlacklist(address addr, bool status) external onlyOwner {
        blacklist[addr] = status;
    }

    function _update(address from, address to, uint256 value) internal override {
        require(!blacklist[from] && !blacklist[to], "Blacklisted");
        require(!transferRestriction || msg.sender == owner(), "Transfers locked");
        super._update(from, to, value);
    }
}
