// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@OpenZeppelin/contracts/token/ERC20/ERC20.sol";
import "@OpenZeppelin/contracts/access/Ownable.sol";

contract WegoToken is ERC20, Ownable {
   
    constructor(string memory name , string memory symbol) ERC20(name , symbol) Ownable(msg.sender) {
       
    }

    function mint(address to , uint256 amount) public onlyOwner  {
       
        _mint(to, amount);
    }
    
}