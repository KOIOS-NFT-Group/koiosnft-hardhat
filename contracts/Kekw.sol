// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import ERC721 token contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Kekw is ERC721Enumerable, Ownable {
  using Strings for uint256;

  uint256 public constant PRICE = 0.001 ether;
  uint256 public constant TOTAL_NUMBER_OF_NFTS = 9999;

  string private _baseTokenURI = "";

  constructor(string memory _name,
        string memory _symbol) ERC721(_name, _symbol) {}

  function mint(uint256 num) public payable {
    uint256 supply = totalSupply();
    require(supply + num <= TOTAL_NUMBER_OF_NFTS);
    require(msg.value >= PRICE * num);
    for (uint256 i; i < num; i++) {
      _safeMint(msg.sender, supply + i);
    }
  }

  function burn(uint256 tokenId) public onlyOwner {
    _burn(tokenId);
  }

  function getBaseURI() public view returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) public onlyOwner {
    _baseTokenURI = baseURI;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(_exists(tokenId), "NFT: URI query for nonexistent token");

    string memory baseURI = getBaseURI();
    string memory json = ".json";
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString(), json))
        : "";
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 tokenCount = balanceOf(_owner);

    uint256[] memory tokensId = new uint256[](tokenCount);
    for (uint256 i; i < tokenCount; i++) {
      tokensId[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokensId;
  }

  function withdrawAll() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  function balanceOfContract() public view onlyOwner returns (uint256) {
    return address(this).balance;
  }
}
