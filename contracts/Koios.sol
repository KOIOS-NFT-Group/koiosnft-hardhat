// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// This is the newest version as of 10-3-2022 REMOVE BEFORE FLIGHT!

contract Koios is ERC721Enumerable, Ownable {

    using Strings for uint256;
    using SafeMath for uint256;

    // Defines the burnable ERC20 token for the contract
    ERC20Burnable public _token; 

    string private _baseTokenURI = "";
    uint256 public _tokenLimit;
    bool public is_revealed = false;
    uint public _totalSupply;

    event tokenMinted(uint tokenID, address minterAddress);
    event IsRevealedChanged(address account);

    // Mapping where we map an address to the amount of tokens minted
    mapping (address => uint256) public _tokensMinted;


    struct KoiosToken {
        uint256 id;
        string uri;
    }

    constructor(string memory _name,
        string memory _symbol, ERC20Burnable token, uint256 maxAmount) ERC721(_name, _symbol) {
            _token = token;
            _totalSupply = maxAmount;
        }

    // Sets the contract for the ERC20 token that is to be paid in order to mint
    function _setContractToken(ERC20Burnable _newTokenAddress) public onlyOwner{
        _token = _newTokenAddress;
    }

    // Sets the amount of NFTs an address is allowed to mint
    function _setTokenlimit(uint256 _newLimit) public onlyOwner{
        _tokenLimit = _newLimit;
    }

    // Sets the total amount of NFTs
    function _setSupply(uint _newSupply) public onlyOwner{
        _totalSupply = _newSupply;
    }

    // Burns 1 ERC20 token from the msg.sender and mints an NFT
    function mint() public {
        address from = msg.sender;
        uint256 supply = totalSupply();

        require(_tokensMinted[from] < _tokenLimit, "maximum amount of mints exceeded!");
        require(supply.add(1) <= _totalSupply, "max supply of NFTs reached!");

        _token.burnFrom(from, (1 ether));

        uint256 newTotalAmount = supply.add(1);

        _safeMint(from, newTotalAmount);
        _tokensMinted[from]++;
        
        emit tokenMinted(newTotalAmount, from); 
    }

    // Gets all tokens in existence witht heir corresponding URI
    function getAllTokens() public view returns (KoiosToken[] memory){
        uint256 supply = totalSupply();
        uint256 counter = 0;
        KoiosToken[] memory res = new KoiosToken[](supply);
            for(uint256 i = 0; i < supply; i++){
                if(_exists(counter)){
                    string memory uri = tokenURI(counter);
                    res[counter] = KoiosToken(counter, uri);
                }
            counter++;
        }
    return res;
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

        if(is_revealed){
            return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString(), json))
            : '';
        }else{
            return baseURI;
        }
    }

    // Gets all tokenIds of given owner
    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensId;
    }

    // Withdraws all ETH on the contract
    function withdrawAll() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    function balanceOfContract() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
    }