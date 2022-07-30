// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  uint public constant THRESHOLD = 1 ether;
  uint public DEADLINE = block.timestamp + 2 days;

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  event Stake(address indexed staker, uint amount);

  mapping(address => uint) public balances;

  function stake() public payable {
    balances[msg.sender] += msg.value;

    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() public {

    require(timeLeft() == 0, "Cannot call 'execute' before the deadline ends!");
    require(address(this).balance >= THRESHOLD, "Cannot call 'execute', threshold not met!");

    (bool success, ) = address(exampleExternalContract).call{value: address(this).balance}(abi.encodeWithSignature("complete()")); 
    require(success, "function 'complete' failed!");
  }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function
  // Add a `withdraw()` function to let users withdraw their balance

  function withdraw(address payable staker) public {

    uint stakerBalance = balances[staker];

    require(timeLeft() == 0, "Cannot call 'withdraw' before the deadline ends!");
    require(stakerBalance > 0, "No ETH staked!");

    balances[staker] = 0;

    (bool success, ) = staker.call{value: stakerBalance}("");
    require(success, "function 'withdraw' failed!");
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns(uint){
    return DEADLINE >= block.timestamp ? DEADLINE - block.timestamp : 0;
  }

  // Add the `receive()` special function that receives eth and calls stake()


}
