pragma solidity ^0.6.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NaiveReceiverLenderPool is ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;

    uint256 private constant FIXED_FEE = 1 ether; // not the cheapest flash loan

    function fixedFee() external pure returns (uint256) {
        return FIXED_FEE;
    }

    function flashLoan(address payable borrower, uint256 borrowAmount) external nonReentrant {
        // @audit no access modifier to check if the callee is actually the borrower or anyone else plus if borrowAmount is greater than zero
        /// @notice attacker can call flashLoan multiple times, set borrower to FlashLoanRecieveEther contract and borrowAmount to zero and drain the borrower
        uint256 balanceBefore = address(this).balance;
        require(balanceBefore >= borrowAmount, "Not enough ETH in pool");

        require(address(borrower).isContract(), "Borrower must be a deployed contract");
        // Transfer ETH and handle control to receiver
        (bool success,) =
            borrower.call{value: borrowAmount}(abi.encodeWithSignature("receiveEther(uint256)", FIXED_FEE));
        require(success, "External call failed");

        require(address(this).balance >= balanceBefore.add(FIXED_FEE), "Flash loan hasn't been paid back");
    }

    // Allow deposits of ETH
    receive() external payable {}
}
