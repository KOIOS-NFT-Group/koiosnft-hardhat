// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Faucet is Ownable {

    mapping(address => bool) public claimedList;

    event faucetFilled(uint256 amount, address account);
    event addressClaimed(address account);

    function deposit()payable public{
        emit faucetFilled(msg.value, msg.sender);
    }

    function getContractBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }

    function claim(address claimer) external onlyOwner {
        require(!claimedList[claimer], "Address has already claimed from the faucet!");
        claimedList[claimer] = true;
        payable(claimer).transfer(0.01 ether);
        emit addressClaimed(claimer);
    }
}