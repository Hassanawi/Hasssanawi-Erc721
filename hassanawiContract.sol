// SPDX-License-Identifier: MIT
  pragma solidity ^0.8.4;


  import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
  import "@openzeppelin/contracts/security/Pausable.sol";
  import "@openzeppelin/contracts/access/Ownable.sol";
  import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
  import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

   /**
   *@title Hassanawi is an Erc 721 token
   *@author Hassan Sarfraz
   */ 

  contract Hassanawi is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable {
     
    //state variables
    bool public publicMint;
    bool public platformMint;
    bool public whitelistUserMint;

    uint public whitelistUserMintingLimit;
    uint public platformMintingLimit;
    uint public totalMintingLimit;
    uint public publicUserMintLimit;
    uint public publicMintingLimit;
    uint whitelistUserMintCount;

    string baseUri;

    /**
     *@dev _whiteListedUser stores the address of whitelisted users
     */
    mapping (address => bool) _whiteListedUser; 
    
    /**
     *@dev _admin stores the address of admin users
     */
    mapping (address => bool) _admin;

    /**
     *@dev _HassanawiMintCount stores the number of token minted by an address
     */
    mapping(address =>uint) _HassanawiMintCount; 

 
    error youAreNotAnAdmin();
    error totalMintCantBeZero();
    error mintingLimitReached();
    error cantMintToZeroAddress();
    error publicMintingNotActive();
    error youAreNotWhiteListUser();
    error platformMintingIsNotActive();
    error whitelistUserMintingNotActive();
    error youHaveReachedYourMintingLimit();
    error totalMintingLimitMustBeGreater();
 
    /**
     *@dev UpdatrBaseUri is emitted when _baseUri is updated by _admin
     */
    event UpdateBaseUri(string _baseUri,address _admin);
    /**
     *@dev SetMintingLimit is emitted when _totalMintLimit, _platformMintLimit, _whitelistMintLimit is set
     */
    event SetMintingLimit(uint _totalMintLimit , uint _platformMintLimit, uint _whitelistMintLimit);

    constructor() ERC721("hassanawi", "Hsk") {
      baseUri ="https://gateway.pinata.cloud/ipfs/" ;
     }
    

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
      if(_admin[msg.sender]!= true){
       revert youAreNotAnAdmin();
      }
      _;
     }

    /**
     * @dev Throws if called by any account other than the whitelistedUser.
     */
    modifier onlyWhiteListedUser() {
      if(_whiteListedUser[msg.sender]!= true){
        revert youAreNotWhiteListUser();
      }
      _;
     }


    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     * - only owner can call this function
     */
    function pause() public onlyOwner {
      _pause();
      emit Paused(msg.sender);
     }
    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     * - only owner can call this funtion
     */
    function unpause() public onlyOwner {
      _unpause();
      emit Unpaused(msg.sender);
     }




    //activate and deactivate Minting

    /**
     *@dev activatePublicMint activates the public minting 
     *@notice onlyOwner can access this function
     *sets the publicMintingLimit
     */

    function activatePublicMint () public whenNotPaused onlyOwner {
      publicMint = true;
      platformMint=false;
      publicMintingLimit = totalMintingLimit-(whitelistUserMintCount + platformMintingLimit); 
     }
    
    /**
     *@dev deactivatePublicMint de-activates the public minting
     *onlyOwner can access this function
     */

    function deAtivatePublicMint () public whenNotPaused onlyOwner {
      publicMint = false;
     }

    /**
     *@dev ativatePlateformMint activates the platformMint 
     *@notice onlyOwner can access this function
     */
    function ativatePlateformMint () public whenNotPaused onlyOwner {
      platformMint = true;
     }

    /**
     *@dev deAtivatePlatformMint de-activates the platformMint
     *onlyOwner can access this function
     */
    function deAtivatePlatformMint () public whenNotPaused onlyOwner {
      platformMint = false;
     } 

    /**
     *@dev ativateWhitelistUserMint activates the whitelistUserMint 
     *onlyOwner can access this function
     */
    function ativateWhitelistUserMint () public whenNotPaused onlyOwner {
      whitelistUserMint = true;
     }
     
    /**
     *@dev deAtivateWhitelistUserMint de-activates the whitelistUserMint
     *onlyOwner can access this function
     */
    function deAtivateWhitelistUserMint () public whenNotPaused onlyOwner {
      whitelistUserMint = false;
     }
    

    /**
     *@dev setMintingLimit sets the _whitelistUserMintLimit, _platformMintLimit, _totalMintLimit
     *onlyOwner can access this function
     *
     *checks _totalMintLimit is not equal to  zero
     *checks _totalMintLimit is greater then (_whitelistUserMintLimit + _platformMintLimit )
     *
     *emits SetMintingLimit
     */
    
    function setMintingLimit(
      uint _whitelistUserMintLimit,
      uint _platformMintLimit,
      uint _totalMintLimit
      )
     public  whenNotPaused onlyOwner
     {
      if (_totalMintLimit == 0){
        revert totalMintCantBeZero();
      }
      if (_totalMintLimit <_whitelistUserMintLimit + _platformMintLimit ){
         revert totalMintingLimitMustBeGreater();
      }
      whitelistUserMintingLimit = _whitelistUserMintLimit;
      platformMintingLimit =_platformMintLimit;
      totalMintingLimit = _totalMintLimit;
      emit SetMintingLimit(_totalMintLimit, _platformMintLimit, _whitelistUserMintLimit);
     }

    /**
     *@dev updateBaseUri updates the baseUri 
     *onlyAdmin can access this function
     */
    function updateBaseUri(string memory _baseUri) public onlyAdmin {
      baseUri =_baseUri;
      emit UpdateBaseUri(_baseUri, msg.sender);
     }




    //adding  Users

    /**
     *@dev addWhiteListedUser add white listed users 
     *onlyAdmin can access this function
     */

    function addWhiteListedUser(address _whitelistUser) public whenNotPaused onlyOwner {
      _whiteListedUser[_whitelistUser]= true;
     }

    /**
     *@dev isWhiteListedUser checks if user address is whitelisted or not
     */
    function isWhiteListedUser(address _user) public view whenNotPaused  returns(bool){
      if (_whiteListedUser[_user]==true){
        return true;
      }
      else {
        return false;
      }
     }
     
    /**
     *@dev addAdmin add admin users 
     *onlyAdmin can access this function
     */
    function addAdmin(address admin) public whenNotPaused  onlyOwner {
      _admin[admin]= true;
     }

    /**
     *@dev isAdmin checks if user address is admin or not
     */
    function isAdmin(address admin) public view whenNotPaused  returns(bool){
      if (_admin[admin]==true){
        return true;
      }
      else {
        return false;
      }
     }  


    //Minting functions



    /**
     * @dev platformMinting mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     * onlyAdmin can access the function
     * platformMint must be active
     * platform minting limit has not reached
     * - `tokenId` must not exist.
     * `to` address must not be a null address
     *
     * Emits a {Transfer} event.
     */
    function platformMinting(
      address to,
      uint256 tokenId,
      string memory hash
      )
     public onlyAdmin whenNotPaused 
     { 
      uint platformTokenCount =0;
      platformTokenCount ++;
      if(platformMint!=true){
        revert platformMintingIsNotActive();
      }
      if(platformTokenCount > platformMintingLimit){
        revert mintingLimitReached();
      }
      if (to == 0x0000000000000000000000000000000000000000){
        revert cantMintToZeroAddress();
      }
      _safeMint(to, tokenId);
      _setTokenURI(tokenId, hash);
     uint num= _HassanawiMintCount[msg.sender];
      _HassanawiMintCount[msg.sender]= num++;
     }  


     /**
     * @dev whitelistUserMinting mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     * onlyWhiteListedUser can access the function
     * whitelistUserMint must be active
     * whitelist User Minting   Limit has not reached
     * `to` address must not be a null address
     *
     * Emits a {Transfer} event.
     */
    function whitelistUserMinting (
      address to,
      uint256 tokenId, 
      string memory hash
      )
     public whenNotPaused onlyWhiteListedUser
     {   
      whitelistUserMintCount ++;
      if(whitelistUserMint!=true){
        revert whitelistUserMintingNotActive();
      }
      if (whitelistUserMintCount > whitelistUserMintingLimit){
        revert mintingLimitReached();
      }
      if (to == 0x0000000000000000000000000000000000000000){
        revert cantMintToZeroAddress();
      }
      _safeMint(to, tokenId);
      _setTokenURI(tokenId, hash);
      uint num= _HassanawiMintCount[msg.sender];
      _HassanawiMintCount[msg.sender]= num++;
     }

     /**
     * @dev publicUserMinting mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     * public Mint must be active
     * Public Mint Limit has not reached
     * address has not minted 5 or more than 5 hassanawi tokens
     * `to` address must not be a null address
     *
     * Emits a {Transfer} event.
     */
    
    function publicUserMinting(
      address to,
      uint256 tokenId,
      string memory hash
      )
     public whenNotPaused 
     {
      uint publicMintCount;
      publicMintCount ++;
      if(publicMint!=true){
        revert publicMintingNotActive();
      }
      if(publicMintCount > platformMintingLimit){
        revert mintingLimitReached();
      }
      if(_HassanawiMintCount[msg.sender]>=5){
        revert youHaveReachedYourMintingLimit();
      }
      if (to == 0x0000000000000000000000000000000000000000){
        revert cantMintToZeroAddress();
      }

      _safeMint(to, tokenId);
      _setTokenURI(tokenId, hash);
      uint num= _HassanawiMintCount[msg.sender];
      _HassanawiMintCount[msg.sender]= num++;
     }

    /**
     * @dev Hook that is called before any (single) token transfer. This includes minting and burning.
     * See {_beforeConsecutiveTokenTransfer}.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
      address from,
      address to,
      uint256 tokenId
     )
     internal whenNotPaused override(ERC721, ERC721Enumerable)
     {
      super._beforeTokenTransfer(from, to, tokenId);
     }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */


    function _burn(uint256 tokenId) internal whenNotPaused  override(ERC721, ERC721URIStorage) {
      super._burn(tokenId);
     }

    
    /**
     * @dev See {HassanawiMetadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
      public
      view
      whenNotPaused 
      override(ERC721, ERC721URIStorage)
      returns (string memory)
     {
      return string(abi.encodePacked(baseUri,super.tokenURI(tokenId)));
     }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
      public
      view
      whenNotPaused 
      override(ERC721, ERC721Enumerable)
      returns (bool)
     {
      return super.supportsInterface(interfaceId);
     }
}