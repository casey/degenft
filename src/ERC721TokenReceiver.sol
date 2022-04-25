// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface ERC721TokenReceiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 id,
    bytes calldata data
  ) external returns(bytes4);
}
