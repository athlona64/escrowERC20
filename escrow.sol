// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
pragma solidity >= 0.4.16 < 6.0.0;

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

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      revert();
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
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert();
    }
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public{
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
  function setLikepoint(address setAddr) onlyOwner  public returns (bool) {
      likepoint = setAddr;
      return true;
  }
  function setPKC(address setAddr) onlyOwner public returns (bool) {
      pkc = setAddr;
      return true;
  }
  function setRate(uint256 set) onlyOwner public returns (bool) {
      rate = set;
      return true;
  }
  
  function checkAddressLikepoint(address token) internal view returns (bool) {
      if(token == address(likepoint)) {
          return true;
      }
  }
  function checkAddressPKC(address token) internal view returns (bool) {
      if(token == address(pkc)) {
          return true;
      }
  }
  function reserveToken(address token, uint256 amount) onlyOwner public {
     tokens[token][address(this)] = tokens[token][address(this)].add(amount);
     if(!ERC20(token).transferFrom(msg.sender, address(this), amount)) revert();
     emit Reserve(token, msg.sender, amount);
  }
  function withdrawByAdmin(address token, uint256 amount) public returns (bool) {
    if (tokens[token][address(this)] < amount) revert();
    tokens[token][address(this)] = tokens[token][address(this)].sub(amount);
    if (token == address(0)) {
      if (!msg.sender.send(amount)) revert();
    } else {
      if (!ERC20(token).transfer(msg.sender, amount)) revert();
    }
    return true;
  }
  function swapLikeToPKC(address token, address token2, uint256 amount) public returns (bool) {
      if(!checkAddressLikepoint(token)) revert();
      if(!checkAddressPKC(token2)) revert();
      tokens[token][address(this)] = tokens[token][address(this)].add(amount);
      if(!ERC20(token).transferFrom(msg.sender, address(this), amount)) revert();
      tokens[token2][address(this)] = tokens[token2][address(this)].sub(amount/rate);
      if (!ERC20(token2).transfer(msg.sender, amount/rate)) revert();
      emit SwapLIKE(token, token2, msg.sender, amount, amount/rate);     
      return true;
  }
  function swapPKCToLike(address token, address token2, uint256 amount) public returns (bool) {
      if(!checkAddressPKC(token)) revert();
      if(!checkAddressLikepoint(token2)) revert();
      tokens[token][address(this)] = tokens[token][address(this)].add(amount);
      if(!ERC20(token).transferFrom(msg.sender, address(this), amount)) revert();
      tokens[token2][address(this)] = tokens[token2][address(this)].sub(amount*rate);
      if (!ERC20(token2).transfer(msg.sender, amount*rate)) revert();
      emit SwapLIKE(token, token2, msg.sender, amount, amount*rate);
      return true;
  }
  

}