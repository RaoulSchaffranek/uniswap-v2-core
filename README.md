# Solar Space for Uniswap V2

This repository is a fork of Uniswap V2, created for educational purposes only. 

**Note:** The changes in this repository are unaudited and should not be used in production environments.

## Features

Explore and debug Uniswap V2 functionality using Solar Space. Here's how:

1. Open this repository in your browser via Solar Space:  
    [https://solarspace.dev/github/RaoulSchaffranek/uniswap-v2-core](https://solarspace.dev/github/RaoulSchaffranek/uniswap-v2-core)
    or via Code Space:
    [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/RaoulSchaffranek/uniswap-v2-core?quickstart=1)

2. Navigate to the `test/DebugV2Pair.sol` file.

3. Use the `▷ Debug`-button above the `debugAddLiquidity` or `debugSwap` functions to start a Simbolik debugging session.

4. Step through the code to observe the behavior of adding liquidity to a Uniswap V2 pair or performing a swap. Experiment with different parameter values to better understand the pricing formula.

## Changelog

The following updates have been made to this repository:

- Added some external contracts from [UniswapV2Periphery](https://github.com/Uniswap/v2-periphery), [UniswapLib](https://github.com/Uniswap/solidity-lib) and [WETH9](https://github.com/gnosis/canonical-weth) for convinience
- Updated all contracts to support `solc` 0.8.*
- Added Foundry configuration
- Integrated Solar Space devcontainer
- Introduced Simbolik entry point
- Replaced `SafeMath` with compiler-checked arithmetic
