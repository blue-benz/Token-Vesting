// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TokenVesting is ReentrancyGuard {
    IERC20 public token;
    address public beneficiary;
    uint256 public start;
    uint256 public duration;
    uint256 public released;
    
    event TokensReleased(uint256 amount);
    
    constructor(
        address _token,
        address _beneficiary,
        uint256 _start,
        uint256 _duration
    ) {
        require(_beneficiary != address(0), "Invalid beneficiary");
        token = IERC20(_token);
        beneficiary = _beneficiary;
        start = _start;
        duration = _duration;
    }
    
    function release() external nonReentrant {
        uint256 releasable = vestedAmount() - released;
        require(releasable > 0, "No tokens to release");
        
        released += releasable;
        token.transfer(beneficiary, releasable);
        emit TokensReleased(releasable);
    }
    
    function vestedAmount() public view returns (uint256) {
        uint256 totalBalance = token.balanceOf(address(this)) + released;
        if (block.timestamp < start) {
            return 0;
        } else if (block.timestamp >= start + duration) {
            return totalBalance;
        } else {
            return (totalBalance * (block.timestamp - start)) / duration;
        }
    }
}
