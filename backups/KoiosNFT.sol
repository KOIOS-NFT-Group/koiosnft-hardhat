// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//import ERC721 token contract from OpenZeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract KoiosNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;
  using SafeMath for uint256;

  // This will be the payable token for the NFTs i.e. Titan tokens for example. 
  IERC20 private _token; 

  // Currently the mint price is 0.001 ether.
  uint256 public constant PRICE = 0.001 ether;
  string private _baseTokenURI = "";
  address public _mintCallerAddress;

  event tokenMinted(uint tokenID, address minterAddress, string tokenType);

  mapping (uint256 => string) _tokenURIs;
  
    struct KoiosNFTToken {
    uint256 id;
    string uri;
  }

  constructor(string memory _name,
        string memory _symbol, IERC20 token) ERC721(_name, _symbol) {
            _token = token;
        }

  function _setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner{
    _tokenURIs[tokenId] = _tokenURI;
  }
  
  // This function allows us to change token addresses that are used to purchase NFTs.
  function _setTokenContractAddress(IERC20 contractAddress) public onlyOwner{
      _token = contractAddress;
  }
  
  // This function allows us to change contracts that are allowed to call the mint function. 
  function _setMintCallerAddress(address mintCallerAddress) public onlyOwner{
      _mintCallerAddress = mintCallerAddress;
  }
  
  // This function was a test to make the function payable with ERC-20 tokens i.e. Titan tokens. 
  function buyHero(uint256 amount) public{
    require(amount == 500|| amount == 1000  || amount == 2000, "Wrong input, valid inputs are: 500, 1000 or 2000.");
    uint256 supply = totalSupply();
    uint256 newTotalAmount = supply.add(1);
    address from = msg.sender; 
    
    _token.transferFrom(from, address(this), amount * (10 ** uint256(18)) );

    _safeMint(msg.sender, newTotalAmount);
    
    if(amount == 500 ){
        emit tokenMinted(newTotalAmount, msg.sender, "Hero"); 
        
    }else if (amount == 1000){
        emit tokenMinted(newTotalAmount, msg.sender, "Legend"); 
        
    }else if(amount == 2000 ){
         emit tokenMinted(newTotalAmount, msg.sender, "Titan"); 
         
     }
 }
 
   // This is the main mint function. It is external so it can be called from other contracts. 
   function mint(address mintAddress) external{

    // Requires that not everyone is allowed to call this function only the set _mintCallerAddress.
    require(msg.sender == _mintCallerAddress);
    uint256 supply = totalSupply();

    uint256 newTotalAmount = supply.add(1);
    _safeMint(mintAddress, newTotalAmount);
    emit tokenMinted(newTotalAmount, mintAddress, "Hero");
 }

  function getAllTokens() public view returns (KoiosNFTToken[] memory){
    uint256 supply = totalSupply();
    uint256 counter = 0;
    KoiosNFTToken[] memory res = new KoiosNFTToken[](supply);
    for(uint256 i = 0; i < supply; i++){
      if(_exists(counter)){
        string memory uri = tokenURI(counter);
        res[counter] = KoiosNFTToken(counter, uri);
      }
      counter++;
    }
    return res;
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
    string memory tokenHash = _tokenURIs[tokenId];
    
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenHash))
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
