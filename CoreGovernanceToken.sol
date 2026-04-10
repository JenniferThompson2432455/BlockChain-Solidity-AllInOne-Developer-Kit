// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoreGovernanceToken is ERC20, Ownable {
    uint256 public constant REWARD_RATE = 10;
    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public rewardDebt;

    constructor() ERC20("Core Governance Token", "CGT") Ownable(msg.sender) {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        _transfer(msg.sender, address(this), amount);
        userStaked[msg.sender] += amount;
        rewardDebt[msg.sender] = calculateReward(msg.sender);
    }

    function unstake(uint256 amount) external {
        require(userStaked[msg.sender] >= amount, "Insufficient stake");
        claimReward();
        userStaked[msg.sender] -= amount;
        _transfer(address(this), msg.sender, amount);
    }

    function calculateReward(address user) public view returns (uint256) {
        return (userStaked[user] * REWARD_RATE) / 1000;
    }

    function claimReward() public {
        uint256 reward = calculateReward(msg.sender) - rewardDebt[msg.sender];
        if (reward > 0) {
            _mint(msg.sender, reward);
        }
        rewardDebt[msg.sender] = calculateReward(msg.sender);
    }
}
