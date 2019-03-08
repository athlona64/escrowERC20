// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
pragma solidity ^0.4.16;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


contract ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ExchangeLikepointToPKC is Ownable {
  using SafeMath for uint;
  event Deposit(address token, address user, uint256 amount, uint256 balance);
  event Withdraw(address token, address user, uint256 amount, uint256 balance);
  event SwapLIKE(address token, address token2, address user, uint256 amount, uint256 balanceReturn);
  event SwapPKC(address token, address token2, address user, uint256 amount, uint256 balanceReturn);
  event Reserve(address token, address user, uint256 amount);
  mapping (address => mapping (address => uint256)) public tokens;
  
  address public likepoint;
  address public pkc;
  uint256 public rate = 100;
  function setLikepoint(address setAddr) onlyOwner returns (bool success) {
      likepoint = setAddr;
  }
  function setPKC(address setAddr) onlyOwner returns (bool success) {
      pkc = setAddr;
  }
  function setRate(uint256 setRate) onlyOwner returns (bool success) {
      rate = setRate;
  }
  
  function reserveToken(address token, uint256 amount) onlyOwner {
     tokens[token][this] = tokens[token][this].add(amount);
     if(!ERC20(token).transferFrom(msg.sender, this, amount)) throw;
     Reserve(token, msg.sender, amount);
  }
  function withdrawByAdmin(address token, uint256 amount) returns (bool success) {
    if (tokens[token][this] < amount) throw;
    tokens[token][this] = tokens[token][this].sub(amount);
    if (token == address(0)) {
      if (!msg.sender.send(amount)) throw;
    } else {
      if (!ERC20(token).transfer(msg.sender, amount)) throw;
    }
  }
  function swapLikeToPKC(address token, address token2, uint256 amount) returns (bool success) {
      require(likepoint != token);
      require(pkc != token2);
      tokens[token][this] = tokens[token][this].add(amount);
      if(!ERC20(token).transferFrom(msg.sender, this, amount)) throw;
      tokens[token2][this] = tokens[token2][this].sub(amount/rate);
      if (!ERC20(token2).transfer(msg.sender, amount/rate)) throw;
      SwapLIKE(token, token2, msg.sender, amount, amount/rate);     
  }
  function swapPKCToLike(address token, address token2, uint256 amount) returns (bool success) {
      require(pkc != token);
      require(likepoint != token2);
      tokens[token][this] = tokens[token][this].add(amount);
      if(!ERC20(token).transferFrom(msg.sender, this, amount)) throw;
      tokens[token2][this] = tokens[token2][this].sub(amount*rate);
      if (!ERC20(token2).transfer(msg.sender, amount*rate)) throw;
      SwapLIKE(token, token2, msg.sender, amount, amount*rate);
  }
  

}