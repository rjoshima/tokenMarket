
pragma solidity ^0.4.18;

contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256);
    // function balanceOf(address _owner) public view returns (uint256);
    function ownerOf(uint256 _tokenId) public view returns (address);
    // function approve(address _to, uint256 _tokenId) external;
    // function transfer(address _to, uint256 _tokenId) external;
    // function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    // event Approval(address owner, address approved, uint256 tokenId);

    // Optional

    // function name() public view returns (string);
    // function symbol() public view returns (string);
    function tokensOfOwner(address _owner) external view returns (uint256[]);


}

contract createToken is ERC721 {
    using SafeMath for uint256;
  /*** CONSTANTS ***/

    // Token name
    string internal name_ = "TokenMarket";

    // Token symbol
    string internal symbol_ = "TM";

    // //     // Token name
    // string internal name_ ;

    // // Token symbol
    // string internal symbol_;
  

    // function createToken(string _name, string _symbol) public {
    //     name_ = _name;
    //     symbol_ = _symbol;
    // }
    constructor(string _name, string _symbol) public {
        name_ = _name;
        symbol_ = _symbol;

    }


    struct Token {
        string name;
        string details;
        uint256 price;
        bool sale;
        uint256 sort;
        address author;
    }

    /* STORAGE */
    Token[] tokens;


    // Mapping from token ID to owner
    mapping (uint256 => address) internal tokenOwner;
    
    // Mapping from owner to number of owned token
    // mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] internal allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) internal allTokensIndex;

    
  //   mapping (uint256 => address) public tokenIndexToApproved;

    /*** EVENTS ***/

    event Mint(address owner, uint256 tokenId);

    /*** INTERNAL FUNCTIONS ***/

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenOwner[_tokenId] == _claimant;
    }


    function mint(string _name, string _details, uint256 _price, bool _sale, uint256 _sort) external returns (uint256) {
        require(msg.sender != address(0));
        
        
        uint256 tokenId = tokens.push(Token({name: _name, details: _details, price: _price, sale: _sale, sort: _sort, author: msg.sender})) - 1;
    
        emit Mint(msg.sender, tokenId);
        _transfer(0, msg.sender, tokenId);
        
        allTokensIndex[tokenId] = allTokens.length;
        allTokens.push(tokenId);
        
        return tokenId;

    }
    

    function purchase(uint256 _tokenId) external payable {
        address oldOwner = tokenOwner[_tokenId];
        address newOwner = msg.sender;
        require(oldOwner != newOwner);
        require(tokens[_tokenId].price <= msg.value);
        require(tokens[_tokenId].sale == true);
        
        Token memory token = tokens[_tokenId];
        uint256 price = token.price;
        require(msg.value >= price);

        _transfer(oldOwner, newOwner, _tokenId);

        tokens[_tokenId].sale = false;

        if (price > 0) {
            newOwner.transfer(price);
        }

    }
    

    function _transfer(address _from, address _to, uint256 _tokenId) internal {

        tokenOwner[_tokenId] = _to;
        // ownedTokensCount[_to] = ownedTokensCount[_to].add(1);

        if (_from != address(0)) {
            uint256 tokenIndex = ownedTokensIndex[_tokenId];
            uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
            uint256 lastToken = ownedTokens[_from][lastTokenIndex];

            ownedTokens[_from][tokenIndex] = lastToken;
            ownedTokens[_from][lastTokenIndex] = 0;
            // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
            // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
            // the lastToken to the first position, and then dropping the element placed in the last position of the list

            ownedTokens[_from].length--;
            ownedTokensIndex[_tokenId] = 0;
            ownedTokensIndex[lastToken] = tokenIndex;


            // ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        
        }

        uint256 length = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;

        emit Transfer(_from, _to, _tokenId);

    }

  
    function totalSupply() public view returns (uint256) {
        return allTokens.length;

    }
    

  // function balanceOf(address _owner) public view returns (uint256) {
  //   require(_owner != address(0));
  //   return ownedTokensCount[_owner];
  // }
    
    function burn(uint256 _tokenId) external {
        require(ownerOf(_tokenId) == msg.sender);

        // require(ownerOf(_tokenId) == msg.sender || msg.sender == ceoAddress);
  
        // ownedTokensCount[msg.sender] = ownedTokensCount[msg.sender].sub(1);
        
        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 lastTokenIndex = allTokens.length.sub(1);
        uint256 lastToken = allTokens[lastTokenIndex];
        allTokens[tokenIndex] = lastToken;
        allTokens[lastTokenIndex] = 0;
        allTokens.length--;
        allTokensIndex[_tokenId] = 0;
        allTokensIndex[lastToken] = tokenIndex;


        
        uint256 ownedtokenIndex = ownedTokensIndex[_tokenId];
        uint256 ownedlastTokenIndex = ownedTokens[msg.sender].length.sub(1);
        uint256 ownedlastToken = ownedTokens[msg.sender][ownedlastTokenIndex];
        ownedTokens[msg.sender][ownedtokenIndex] = ownedlastToken;
        ownedTokens[msg.sender][ownedlastTokenIndex] = 0;
        ownedTokens[msg.sender].length--;

        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = ownedtokenIndex;

        tokenOwner[_tokenId] = address(0);
        
        emit Transfer(msg.sender, address(0), _tokenId);
    }
    
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

      
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }
      
    function tokensOfOwner(address _owner) external view returns (uint256[]) {
        return ownedTokens[_owner];
    }
    
    function tokensOfAll() external view returns (uint256[]) {
        return allTokens;
    }


    function getToken(uint256 _tokenId) external view returns (string tName, string details, uint256 price, bool sale, address owner, address author, uint256 sort) {
        
        Token memory token = tokens[_tokenId];
        
        tName = token.name;
        details = token.details;
        price = token.price;
        sale = token.sale;
        owner = tokenOwner[_tokenId];
        author = token.author;
        sort = token.sort;

    }
     
    function quitSoldToken(uint256 _tokenId, bool sale) external onlyOwnerOf(_tokenId) {
        tokens[_tokenId].sale = sale; 
      
    }

    function soldToken(uint256 _tokenId, bool sale) external onlyOwnerOf(_tokenId) {      
        tokens[_tokenId].sale = sale;       

    }
}


library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}