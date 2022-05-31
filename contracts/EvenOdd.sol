// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./VRFv2Consumer.sol";

contract EvenOdd is Ownable, VRFv2Consumer {
  uint8 constant EVEN_DOOR = 0;
  uint8 constant ODD_DOOR = 1;
  uint8 constant FEE_RATE = 2;

  uint256 randNonce = 0;

  struct BetTime {
    address addr;
    uint256 value;
    uint8 door;
  }

  BetTime[] public betTimes;
  uint256 betTimeOffset = 0;

  event BetEvent(address addr, uint256 value, uint8 door);
  event DoorOpenEvent(uint8 door);

  function bet(uint8 _door) external payable {
    require(_door == EVEN_DOOR || _door == ODD_DOOR);
    require(msg.value > 0);
    betTimes.push(BetTime(msg.sender, msg.value, _door));
    emit BetEvent(msg.sender, msg.value, _door);
  }

  function randomDoor() external onlyOwner {
    randNonce++;
    uint8 door = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 2);
    for (uint256 i = betTimeOffset; i < betTimes.length; i++) {
      BetTime memory betTime = betTimes[i];
      if (betTime.door == door) {
        payable(betTime.addr).transfer(2 * betTime.value - (betTime.value * FEE_RATE) / 100);
      }
    }
    betTimeOffset = betTimes.length;
    emit DoorOpenEvent(door);
  }

  function getTotalBet() external view returns (uint256, uint256) {
    uint256 totalEven = 0;
    uint256 totalOdd = 0;
    for (uint256 i = betTimeOffset; i < betTimes.length; i++) {
      BetTime memory betTime = betTimes[i];
      if (betTime.door == EVEN_DOOR) {
        totalEven += betTime.value;
      } else if (betTime.door == ODD_DOOR) {
        totalOdd += betTime.value;
      }
    }
    return (totalEven, totalOdd);
  }

  function getBalance() external view onlyOwner returns (uint256) {
    return address(this).balance;
  }
}
