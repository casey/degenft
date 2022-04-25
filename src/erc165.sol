// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface ERC165 {
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
