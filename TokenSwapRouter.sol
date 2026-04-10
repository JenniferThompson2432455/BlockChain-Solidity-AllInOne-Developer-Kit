// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSwapRouter is Ownable {
    address public immutable factory;
    uint256 public constant SLIPPAGE = 50;

    constructor(address _factory) Ownable(msg.sender) {
        factory = _factory;
    }

    function swapExactTokensForTokensSimple(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address to
    ) external returns (uint256 amountOut) {
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        uint256 reserveIn = IERC20(tokenIn).balanceOf(address(this));
        uint256 reserveOut = IERC20(tokenOut).balanceOf(address(this));
        amountOut = (amountIn * 99 * reserveOut) / (reserveIn * 100 + amountIn * 99);
        require(amountOut >= minAmountOut, "Slippage too high");
        IERC20(tokenOut).transfer(to, amountOut);
    }

    function getSwapAmount(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256) {
        uint256 rIn = IERC20(tokenIn).balanceOf(address(this));
        uint256 rOut = IERC20(tokenOut).balanceOf(address(this));
        return (amountIn * 99 * rOut) / (rIn * 100 + amountIn * 99);
    }
}
