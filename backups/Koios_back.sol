// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import ERC721 token contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// This is the newest version as of 20-1-2022 REMOVE BEFORE FLIGHT!

contract Koios is ERC721Enumerable, Ownable {

    using Strings for uint256;
    using SafeMath for uint256;

    ERC20Burnable public _token; 

    string private _baseTokenURI = "";
    uint256 public _tokenLimit;
    bool public is_revealed = false;

    event tokenMinted(uint tokenID, address minterAddress);
    event tokenBurned(uint tokenID, address burnerAddress);

    mapping (uint256 => string) _tokenURIs;
    mapping (address => uint256) public _tokensMinted;

    struct KekwToken {
        uint256 id;
        string uri;
    }

    constructor(string memory _name,
        string memory _symbol, ERC20Burnable token) ERC721(_name, _symbol) {
            _token = token;
        }

    function _setContractToken(ERC20Burnable _newTokenAddress) public onlyOwner{
        _token = _newTokenAddress;
    }

    function _setTokenlimit(uint256 _newLimit) public onlyOwner{
        _tokenLimit = _newLimit;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner{
        _tokenURIs[tokenId] = _tokenURI;
    }

    function mint() public {
        require(_tokensMinted[msg.sender] < _tokenLimit, "maximum amount of mints exceeded!");
        uint256 supply = totalSupply();
        address from = msg.sender;

        _token.burnFrom(from, 1 );

        uint256 newTotalAmount = supply.add(1);

        _safeMint(msg.sender, newTotalAmount);
        _tokensMinted[msg.sender].add(1);
        
        emit tokenMinted(newTotalAmount, msg.sender); 
    }

    function getAllTokens() public view returns (KekwToken[] memory){
        uint256 supply = totalSupply();
        uint256 counter = 0;
        KekwToken[] memory res = new KekwToken[](supply);
            for(uint256 i = 0; i < supply; i++){
                if(_exists(counter)){
                    string memory uri = tokenURI(counter);
                    res[counter] = KekwToken(counter, uri);
                }
            counter++;
        }
    return res;
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
        emit tokenBurned(tokenId, msg.sender);
    }

    function getBaseURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }


  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "tokenID does not exist.");

    string memory baseURI = _baseURI();
    string memory json = ".json";

    if(is_revealed){
      return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString(), json))
        : '';
    }else{
      return baseURI;
    }
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