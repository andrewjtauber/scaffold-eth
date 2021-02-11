pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {

  event Stake(address,uint256);
  event Withdraw(address,uint256);
  event DeadlineReached();


  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;

  uint256 public constant threshold = 1 ether;
  uint256 public deadline = now + 60 seconds;

  bool withdrawAllowed = false;

  uint256 public totalStaked = 0;

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(timeLeft() > 0, "Deadline Reached");
    // Update balances
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public notCompleted {
    // Check deadline has been reached
    require(timeLeft() == 0, "Deadline must be reached");
    require(balances[msg.sender] > 0, "Nothing Staked");
    checkWithdrawPolicy();
    require(!withdrawAllowed, "Did Not Pass Threshold Before Deadline");
    if (address(this).balance > threshold){
      exampleExternalContract.complete{value: address(this).balance}();
    }
  }

    // Withdraw function
  function withdraw(address payable _address) public notCompleted {
    checkWithdrawPolicy();
    require(timeLeft() == 0, "deadline must be reached");
    require(withdrawAllowed, "Passed threshold please execute");
    require(balances[_address] > 0, "Balance must be > 0");
    uint256 amount = balances[_address];
    _address.transfer(amount);
    emit Withdraw(msg.sender, balances[msg.sender]);
    balances[_address] = 0;
  }


  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function checkWithdrawPolicy()  public {
  if (address(this).balance <= threshold) {
     withdrawAllowed = true;
  }
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
    if (now >= deadline) {
      return 0;
    } else {
      return (deadline - now);
    }
  }

  modifier notCompleted() {
    bool isContractCompleted = exampleExternalContract.completed();
    require(!isContractCompleted, "ExampleExternalContract Completed");
    _;
  }

}
