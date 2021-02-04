pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
//import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract YourContract {

  event SetPurpose(address sender, string purpose);

  string public purpose = "🛠 Programming Unstoppable Money";

  address public owner;

  address[] private stakers;
  mapping(address => uint256) private balances;
  uint256 public constant threshold = 1 ether;
  mapping(address => bool) private hasStaked;

  string public publicString = "PublicString";
  string private privateString = "privateString";

  uint256 public stakedAmmount;


  constructor() public {
    // what should we do on deploy?
    owner = msg.sender;
  }

  function setPurpose(string memory newPurpose) public {
    //require(msg.sender == owner, "ERROR: not owner");
    purpose = newPurpose;
    console.log(msg.sender,"set purpose to",purpose);
    emit SetPurpose(msg.sender, purpose);
  }

  // Stake
  function Stake(uint256 _amount) public {
    // Require amount is more than 0
    require(_amount > 0, "ammount cannot be 0 or less");

    // Transfer ETH to this contact from the staker
    //("ETH_placholder").transferfrom(msg.sender, address(this), _amount);
    // TODO: Check they have the balance
    //ether.transferfrom(msg.sender, address(this), _amount);

    // Update Amount Staked
    balances[msg.sender] = balances[msg.sender] + _amount;
    //stakedAmmount = balances[msg.sender];
    // Add user to stakers array *only* if they haven't staked already
    if(!hasStaked[msg.sender]) {
      stakers.push(msg.sender);
    }
  }

  // Find the amount an address has staked'
  function getAmountStaked(address _address) public returns (uint256)  {
    if (hasStaked[_address] != false) {
        stakedAmmount = balances[_address];
    } else {
      stakedAmmount = 0;
    }
  }

}
