// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Interface that allows us to call the mint function from the KoiosNFT contract. 
interface IKoiosNFT {
    function mint(address mintAddress) external;
}

contract MintCaller {
    uint256 public constant PRICE = 0.001 ether;
    address _NFTContractAddress;
      
    constructor(address NFTContractAddress) {
        _NFTContractAddress = NFTContractAddress;
    }

    // This is the function that is payable (currently priced as 0.001 ether), would have to change to payable with ERC-20. 
     function payNFT()public payable{
         require(msg.value >= PRICE);
         mintNFT();
     }
     
     // Mint function that calls mint from the main contract. Note the msg.sender: 
     // this is used to the minted NFT gets send to the person acutally minting instead of this contract. 
    function mintNFT() internal{
        IKoiosNFT(_NFTContractAddress).mint(msg.sender);
 }
}