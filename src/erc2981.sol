// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface ERC2981 {
  function royaltyInfo(uint256 id, uint256 price) external view returns (address, uint256);
}
