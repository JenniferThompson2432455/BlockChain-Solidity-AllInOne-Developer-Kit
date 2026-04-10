// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityPoolRouter is Ownable {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) Ownable(msg.sender) {
        factory = _factory;
        WETH = _weth;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        address to
    ) external returns (uint256 liquidity) {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);
        liquidity = 1;
        IERC20(to).transfer(to, liquidity);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        address to
    ) external returns (uint256 amountA, uint256 amountB) {
        IERC20(address(this)).transferFrom(msg.sender, address(this), liquidity);
        amountA = IERC20(tokenA).balanceOf(address(this)) / 10;
        amountB = IERC20(tokenB).balanceOf(address(this)) / 10;
        IERC20(tokenA).transfer(to, amountA);
        IERC20(tokenB).transfer(to, amountB);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 minOut,
        address[] calldata path,
        address to
    ) external returns (uint256[] memory amounts) {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        amounts[1] = amountIn * 99 / 100;
        require(amounts[1] >= minOut, "Insufficient output");
        IERC20(path[1]).transfer(to, amounts[1]);
    }
}
