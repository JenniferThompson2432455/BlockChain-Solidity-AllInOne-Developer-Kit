// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVesting is Ownable {
    struct VestingSchedule {
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
    }

    IERC20 public immutable token;
    mapping(address => VestingSchedule) public vestings;

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function createVesting(
        address beneficiary,
        uint256 total,
        uint256 start,
        uint256 cliffTime,
        uint256 vestDuration
    ) external onlyOwner {
        require(vestings[beneficiary].totalAmount == 0, "Exists");
        require(cliffTime <= vestDuration, "Invalid cliff");
        vestings[beneficiary] = VestingSchedule(total, 0, start, cliffTime, vestDuration);
    }

    function release() external {
        VestingSchedule storage vest = vestings[msg.sender];
        require(vest.totalAmount > 0, "No vesting");
        uint256 releasable = calculateReleasable(msg.sender);
        require(releasable > 0, "Nothing to release");
        vest.releasedAmount += releasable;
        token.transfer(msg.sender, releasable);
    }

    function calculateReleasable(address beneficiary) public view returns (uint256) {
        VestingSchedule memory vest = vestings[beneficiary];
        if (block.timestamp < vest.startTime + vest.cliff) return 0;
        if (block.timestamp >= vest.startTime + vest.duration) return vest.totalAmount - vest.releasedAmount;
        uint256 timeElapsed = block.timestamp - vest.startTime;
        return (vest.totalAmount * timeElapsed) / vest.duration - vest.releasedAmount;
    }
}
