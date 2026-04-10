// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YieldFarmingPool is Ownable {
    IERC20 public immutable lpToken;
    IERC20 public immutable rewardToken;

    uint256 public rewardPerBlock;
    uint256 public startBlock;
    uint256 public endBlock;

    mapping(address => uint256) public stakeAmount;
    mapping(address => uint256) public rewardDebt;
    uint256 public totalStaked;
    uint256 public accRewardPerShare;

    constructor(address lp, address reward, uint256 rpb, uint256 start, uint256 end) Ownable(msg.sender) {
        lpToken = IERC20(lp);
        rewardToken = IERC20(reward);
        rewardPerBlock = rpb;
        startBlock = start;
        endBlock = end;
    }

    function updatePool() public {
        if (block.number <= startBlock || totalStaked == 0) return;
        uint256 last = block.number > endBlock ? endBlock : block.number;
        uint256 blocks = last - startBlock;
        uint256 reward = blocks * rewardPerBlock;
        accRewardPerShare += (reward * 1e18) / totalStaked;
        startBlock = last;
    }

    function stake(uint256 amount) external {
        updatePool();
        lpToken.transferFrom(msg.sender, address(this), amount);
        stakeAmount[msg.sender] += amount;
        totalStaked += amount;
        rewardDebt[msg.sender] = stakeAmount[msg.sender] * accRewardPerShare / 1e18;
    }

    function unstake(uint256 amount) external {
        updatePool();
        stakeAmount[msg.sender] -= amount;
        totalStaked -= amount;
        lpToken.transfer(msg.sender, amount);
        rewardDebt[msg.sender] = stakeAmount[msg.sender] * accRewardPerShare / 1e18;
    }

    function claim() external {
        updatePool();
        uint256 reward = stakeAmount[msg.sender] * accRewardPerShare / 1e18 - rewardDebt[msg.sender];
        rewardToken.transfer(msg.sender, reward);
        rewardDebt[msg.sender] = stakeAmount[msg.sender] * accRewardPerShare / 1e18;
    }
}
