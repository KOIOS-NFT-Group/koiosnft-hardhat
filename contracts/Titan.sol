// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Titan is ERC20Burnable, Ownable {

  constructor(string memory _name,
        string memory _symbol) ERC20(_name, _symbol) {
            _mint(msg.sender, (20000 * (10 ** uint256(18))));
        }

}