// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
pragma solidity ^0.5.0;

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

contract contractB {
  address tracker_0x_address = 0xDc015a2B5d93065c000266c3fdE76DeB173F6919; // ContractA Address
  mapping ( address => uint256 ) public balances;

  function approvalTransfers(uint tokens) public {
      ERC20(tracker_0x_address).approve(address(this), tokens);
  }
  function deposit(uint tokens) public returns (bool success){

    // add the deposited tokens into existing balance 
    balances[msg.sender]+= tokens;

    // transfer the tokens from the sender to this contract
    return ERC20(tracker_0x_address).transferFrom(msg.sender, address(this), tokens);
    
  }
  function checkBalance() public view returns (uint balance){
      return ERC20(tracker_0x_address).balanceOf(msg.sender);
  }

  function transferMan(address to, uint tokens) public {
      ERC20(tracker_0x_address).transfer(to, tokens);
  }
  function returnTokens() public {
    balances[msg.sender] = 0;
    ERC20(tracker_0x_address).transfer(msg.sender, balances[msg.sender]);
  }

}
