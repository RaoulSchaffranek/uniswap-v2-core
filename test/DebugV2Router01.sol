// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { UniswapV2Router01 } from "../contracts/UniswapV2Router01.sol";
import { UniswapV2Factory } from "../contracts/UniswapV2Factory.sol";
import { UniswapV2Pair } from "../contracts/UniswapV2Pair.sol";
import { MockERC20 } from "./MockERC20.sol";
import { WETH9 } from "../contracts/WETH9.sol";

contract DebugV2Router01 {

    MockERC20 public tokenA;
    MockERC20 public tokenB;
    WETH9 public weth;
    
    UniswapV2Router01 public router;
    UniswapV2Factory public factory;
    UniswapV2Pair public pair;
    LiquidityProvider public alice;
    Swapper public bob;

    function setUp() public {
        // Initialize DEX
        tokenA = new MockERC20("Token A", "TKA");
        tokenB = new MockERC20("Token B", "TKB");
        weth = new WETH9();
        factory = new UniswapV2Factory(address(this));
        pair = UniswapV2Pair(factory.createPair(address(tokenA), address(tokenB)));
        router = new UniswapV2Router01(address(factory), address(weth));

        // Inititalize actors
        alice = new LiquidityProvider(address(tokenA), address(tokenB), payable(address(router)));
        tokenA.mint(address(alice), 1000 ether);
        tokenB.mint(address(alice), 1000 ether);
        bob = new Swapper(address(tokenA), address(tokenB), payable(address(router)));
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
        // Bob swaps 10e18 tokenA for the spot price
        bob.swapAforB(10 ether);
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
    address payable public router;

    constructor(address _tokenA, address _tokenB, address payable _router) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        router = _router;
    }

    function provideLiquidity(uint256 amountA, uint256 amountB) external returns (uint256) {
        MockERC20(tokenA).approve(router, amountA);
        MockERC20(tokenB).approve(router, amountB);
        (uint256 _amountA, uint256 _amountB, uint256 shares) = UniswapV2Router01(router).addLiquidity(
            tokenA,
            tokenB,
            amountA,
            amountB,
            0,
            0,
            address(this),
            block.timestamp
        );
        return shares;
    }

    function removeLiquidity(uint256 shares) external {
        address pair = UniswapV2Factory(UniswapV2Router01(router).factory()).getPair(tokenA, tokenB);
        UniswapV2Pair(pair).approve(router, shares);
        UniswapV2Router01(router).removeLiquidity(
            tokenA,
            tokenB,
            shares,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
}

contract Swapper {
    address public tokenA;
    address public tokenB;
    address payable public router;

    constructor(address _tokenA, address _tokenB, address payable _router) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        router = _router;
    }

    function swapAforB(uint256 amountIn) external {
        MockERC20(tokenA).approve(router, amountIn);
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        UniswapV2Router01(router).swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBforA(uint256 amountIn) external {
        MockERC20(tokenB).approve(router, amountIn);
        address[] memory path = new address[](2);
        path[0] = tokenB;
        path[1] = tokenA;
        UniswapV2Router01(router).swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}