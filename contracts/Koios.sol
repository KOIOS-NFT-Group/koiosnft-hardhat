// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract KoiosNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    // Defines the burnable ERC20 token for the contract
    ERC20Burnable constant public _token = ERC20Burnable(0xB49750AD82d11C12209A837210AB753AB09115a7); // Titan token on Polygon
    uint constant public _totalSupply = 1000;
    uint256 constant public _tokenLimit = 2;

    string private _baseTokenURI = "";    
    bool public is_revealed = false;
    
    event tokenMinted(uint tokenID, address minterAddress);
    event IsRevealedChanged(address account);

    // Mapping where we map an address to the amount of tokens minted
    mapping (address => uint256) public _tokensMinted;

    constructor() ERC721("KOIOSNFT", "KOIOSNFT") {           
    }

    // Burns 1 ERC20 token from the msg.sender and mints an NFT
    function mint() public {
        address from = msg.sender;
        uint256 newTotalAmount = totalSupply() + 1;

        require(_tokensMinted[from] < _tokenLimit, "maximum amount of mints exceeded!");
        require(newTotalAmount <= _totalSupply, "max supply of NFTs reached!");

        _token.burnFrom(from, (1 ether)); // Burn 1 Titan token
        _tokensMinted[from]++;
        _safeMint(from, newTotalAmount);

        emit tokenMinted(newTotalAmount, from); 
    }
   
    // Toggles the revealed property
    function toggleRevealed() public onlyOwner {
        is_revealed = !is_revealed;
        emit IsRevealedChanged(msg.sender);
    }

    function getBaseURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "tokenID does not exist.");
        string memory baseURI = getBaseURI();
        string memory json = ".json";

        if (!is_revealed) 
           return baseURI;
        if (bytes(baseURI).length == 0)
           return '';
        return string(abi.encodePacked(baseURI, tokenId.toString(), json));
    }
   
}
