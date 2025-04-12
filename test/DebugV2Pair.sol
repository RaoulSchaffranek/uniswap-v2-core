// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { UniswapV2Factory } from "../contracts/UniswapV2Factory.sol";
import { UniswapV2Pair } from "../contracts/UniswapV2Pair.sol";
import { MockERC20 } from "./MockERC20.sol";

contract DebugV2Pair {

    MockERC20 public tokenA;
    MockERC20 public tokenB;
    
    UniswapV2Factory public factory;
    UniswapV2Pair public pair;
    LiquidityProvider public alice;
    Swapper public bob;

    function setUp() public {
        // Initialize DEX
        tokenA = new MockERC20("Token A", "TKA");
        tokenB = new MockERC20("Token B", "TKB");
        factory = new UniswapV2Factory(address(this));
        pair = UniswapV2Pair(factory.createPair(address(tokenA), address(tokenB)));

        // Inititalize actors
        alice = new LiquidityProvider(address(tokenA), address(tokenB), address(pair));
        tokenA.mint(address(alice), 1000 ether);
        tokenB.mint(address(alice), 1000 ether);
        bob = new Swapper(address(tokenA), address(tokenB), address(pair));
        tokenA.mint(address(bob), 1000 ether);
        tokenB.mint(address(bob), 1000 ether);
    }

    function debugAddLiquidity() external {
        // Alice provides liquidity
        uint256 shares = alice.provideLiquidity(100 ether, 100 ether);
        return;
    }

    function debugSwap() external {
        // Alice provides liquidity
        uint256 shares = alice.provideLiquidity(100 ether, 100 ether);
        // Bob swaps 10e18 tokenA for 1 tokenB
        // This price is way too high, but Uniswap doesn't care
        // It's Bob's responsibility to set reasonable risk parameters
        bob.swapAforB(10 ether, 1 wei);
        // Alice removes liquidity
        alice.removeLiquidity(shares);

        uint256 aliceBalanceA = tokenA.balanceOf(address(alice));
        uint256 aliceBalanceB = tokenB.balanceOf(address(alice));
        uint256 bobBalanceA = tokenA.balanceOf(address(bob));
        uint256 bobBalanceB = tokenB.balanceOf(address(bob));
        return;
    }

}

contract LiquidityProvider {
    address public tokenA;
    address public tokenB;
    address public pair;

    constructor(address _tokenA, address _tokenB, address _pair) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        pair = _pair;
    }

    function provideLiquidity(uint256 amountA, uint256 amountB) external returns (uint256) {
        MockERC20(tokenA).transfer(pair, amountA);
        MockERC20(tokenB).transfer(pair, amountB);
        uint256 shares = UniswapV2Pair(pair).mint(address(this));
        return shares;
    }

    function removeLiquidity(uint256 shares) external {
        UniswapV2Pair(pair).transfer(pair, shares);
        UniswapV2Pair(pair).burn(address(this));
    }
}

contract Swapper {
    address public tokenA;
    address public tokenB;
    address public pair;

    constructor(address _tokenA, address _tokenB, address _pair) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        pair = _pair;
    }

    function swapAforB(uint256 amountIn, uint256 amountOut) external {
        MockERC20(tokenA).transfer(pair, amountIn);
        UniswapV2Pair(pair).swap(0, amountOut, address(this), new bytes(0));
    }

    function swapBforA(uint256 amountIn, uint256 amountOut) external {
        MockERC20(tokenB).transfer(pair, amountIn);
        UniswapV2Pair(pair).swap(amountOut, 0, address(this), new bytes(0));
    }
}