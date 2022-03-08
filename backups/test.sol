// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract KoiosBadgeBulk is ERC1155PresetMinterPauser { // this adds the mint function
    bool public transfersEnabled=false; // initially disable transfers
    //Also inherits the following roles: 'DEFAULT_ADMIN_ROLE', 'MINTER_ROLE' and 'PAUSER_ROLE'
    bytes32 public constant ENABLETRANSFER_ROLE = keccak256("ENABLETRANSFER_ROLE");
    bytes32 public constant TRANSFER_ROLE       = keccak256("TRANSFER_ROLE"); // whitelist for transfers
    bytes32 public constant BULKMINT_ROLE       = keccak256("BULKMINT_ROLE"); // whitelist for bulk mints

    struct infoId {
         string  ipfsCid;
         string  name;
         string  description;
    }
    mapping(uint256 => infoId) public infoIds;
    
    constructor () ERC1155PresetMinterPauser("") { 
       _setupRole(ENABLETRANSFER_ROLE, _msgSender());
       _setupRole(TRANSFER_ROLE, _msgSender());
       _setupRole(BULKMINT_ROLE, _msgSender());
    }   
  
    function name() public pure returns (string memory) { // not really part of standard
        return "Koios badges";
    }
  
    function symbol() public pure returns (string memory) { // not really part of standard
        return "KB";
    }

    function enableTransfers(bool _transfersEnabled) public { // enable/disable transfers
        require(hasRole(ENABLETRANSFER_ROLE, _msgSender()), "Must have enabletransfer role to change");
        transfersEnabled = _transfersEnabled;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155PresetMinterPauser) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data); // check paused
        if (transfersEnabled     ||
            from == address(0)   ||
            hasRole(TRANSFER_ROLE, operator) ||
            hasRole(TRANSFER_ROLE, from) ||
            hasRole(TRANSFER_ROLE, to) 
        ) {
            return;  // transaction is ok
        }
        revert("Transfers disabled");
    }
    
    function mintBulk(address[] calldata recipients,uint256 id) public  {     
        bytes memory data; // empty
        require(hasRole(MINTER_ROLE, _msgSender()),   "Must have minter role");
        require(hasRole(BULKMINT_ROLE, _msgSender()), "Must have bulkmint role");
        for(uint256 i=0; i<recipients.length; i++)          
           _mint(recipients[i], id, 1,data ); // also requires TRANSFER_ROLE // 1 at a time, no data
    }    

    function uri(uint256 id) public view override returns (string memory) {   
        string memory json = Base64.encode(bytes(string(abi.encodePacked(
            '{',
                '"name": "',        infoIds[id].name,        '",',
                '"description": "', infoIds[id].description, '",',
                '"image": "ipfs://',infoIds[id].ipfsCid,     '"',
            '}' 
        ) ) ) );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function defineId(uint256 id, string memory ipfsCid,string memory badgename,string memory description) public  {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Must have admin role to define id");
        infoIds[id]=infoId(ipfsCid,badgename,description);
    }
}