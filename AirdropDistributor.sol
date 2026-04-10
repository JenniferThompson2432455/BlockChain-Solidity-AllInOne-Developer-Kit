// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AirdropDistributor is Ownable {
    IERC20 public immutable token;

    event AirdropSent(address indexed to, uint256 amount);
    event BatchAirdropSent(uint256 count, uint256 total);

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function sendAirdrop(address to, uint256 amount) external onlyOwner {
        token.transfer(to, amount);
        emit AirdropSent(to, amount);
    }

    function batchAirdrop(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Mismatch");
        uint256 total;
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transfer(recipients[i], amounts[i]);
            total += amounts[i];
            emit AirdropSent(recipients[i], amounts[i]);
        }
        emit BatchAirdropSent(recipients.length, total);
    }

    function withdrawRemaining() external onlyOwner {
        uint256 bal = token.balanceOf(address(this));
        token.transfer(msg.sender, bal);
    }
}
