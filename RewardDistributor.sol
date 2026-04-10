// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardDistributor is Ownable {
    IERC20 public immutable rewardToken;
    uint256 public totalDistributed;

    event RewardDistributed(address indexed to, uint256 amount);
    event BatchRewardsDistributed(uint256 count, uint256 total);

    constructor(address token) Ownable(msg.sender) {
        rewardToken = IERC20(token);
    }

    function distributeReward(address to, uint256 amount) external onlyOwner {
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient");
        rewardToken.transfer(to, amount);
        totalDistributed += amount;
        emit RewardDistributed(to, amount);
    }

    function batchDistribute(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Mismatch");
        uint256 total;
        for (uint256 i = 0; i < recipients.length; i++) {
            rewardToken.transfer(recipients[i], amounts[i]);
            total += amounts[i];
            emit RewardDistributed(recipients[i], amounts[i]);
        }
        totalDistributed += total;
        emit BatchRewardsDistributed(recipients.length, total);
    }

    function withdrawRemaining() external onlyOwner {
        uint256 bal = rewardToken.balanceOf(address(this));
        rewardToken.transfer(msg.sender, bal);
    }
}
