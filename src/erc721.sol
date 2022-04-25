// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

interface ERC721 {
  event Approval(address indexed owner, address indexed approved, uint256 indexed id);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
  event Transfer(address indexed from, address indexed to, uint256 indexed id);
  function approve(address approved, uint256 id) external;
  function balanceOf(address owner) external view returns (uint256);
  function getApproved(uint256 id) external view returns (address);
  function isApprovedForAll(address owner, address operator) external view returns (bool);
  function ownerOf(uint256 id) external view returns (address);
  function safeTransferFrom(address from, address to, uint256 id) external;
  function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) external;
  function setApprovalForAll(address operator, bool approved) external;
  function transferFrom(address from, address to, uint256 id) external;
}
