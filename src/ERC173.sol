// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface ERC173 {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function owner() view external returns(address);
  function transferOwnership(address _newOwner) external;
}
