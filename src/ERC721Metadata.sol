// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface ERC721Metadata {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function tokenURI(uint256 id) external view returns (string memory);
}
