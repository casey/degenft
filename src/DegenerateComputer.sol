// SPDX-License-Identifier: CC0-1.0
//
// $ degenerate apply save
//
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████
// ████████████████████████████████

pragma solidity ^0.8.13;

import "src/ERC165.sol";
import "src/ERC173.sol";
import "src/ERC2981.sol";
import "src/ERC721.sol";
import "src/ERC721Metadata.sol";
import "src/ERC721TokenReceiver.sol";

contract DegenerateComputer is ERC165, ERC173, ERC2981, ERC721, ERC721Metadata {
  address private _contractOwner;
  mapping(address => mapping(address => bool)) private _approvedForAll;
  mapping(address => uint256) private _balances;
  mapping(uint256 => address) private _tokenOwners;
  mapping(uint256 => address) private _approved;
  mapping(uint256 => string) private _metadata;
  uint256 private _programCounter;

  modifier ownerOnly() {
    require(msg.sender == _contractOwner);
    _;
  }

  constructor() {
    _contractOwner = msg.sender;
  }

  function compile(string calldata metadata) external ownerOnly {
    uint256 id = _programCounter++;
    _metadata[id] = metadata;
    _balances[_contractOwner]++;
    _tokenOwners[id] = _contractOwner;
    emit Transfer(address(0), _contractOwner, id);
    invokeReceiver(address(0), _contractOwner, id, new bytes(0));
  }

  function programCounter() external view returns (uint256) {
    return _programCounter;
  }

  function recompile(string calldata metadata, uint256 id) external ownerOnly {
    require(_tokenOwners[id] == _contractOwner);
    _metadata[id] = metadata;
  }

  function invokeReceiver(address from, address to, uint256 id, bytes memory data) private {
    require(
      to.code.length == 0 ||
        ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
        ERC721TokenReceiver.onERC721Received.selector
    );
  }

  // ERC165

  function supportsInterface(bytes4 id) external pure returns (bool) {
    // ERC165, ERC173, ERC2981, ERC721, and ERC721Metadata
    return id == 0x01ffc9a7 || id == 0x7f5828d0 || id == 0x2a55205a || id == 0x80ac58cd || id == 0x5b5e139f;
  }

  // ERC165

  function owner() view external returns(address) {
    return _contractOwner;
  }

  function transferOwnership(address _newOwner) external ownerOnly {
    address previousOwner = _contractOwner;
    _contractOwner = _newOwner;
    emit OwnershipTransferred(previousOwner, _newOwner);
  }


  // ERC2981

  function royaltyInfo(uint256, uint256 price) external view returns (address, uint256) {
    return (_contractOwner, price * 10 / 100);
  }

  // ERC721

  function approve(address spender, uint256 id) external {
    address tokenOwner = _tokenOwners[id];
    require(msg.sender == tokenOwner || _approvedForAll[tokenOwner][msg.sender]);
    _approved[id] = spender;
    emit Approval(tokenOwner, spender, id);
  }

  function balanceOf(address tokenOwner) external view returns (uint256) {
    require(tokenOwner != address(0));
    return _balances[tokenOwner];
  }

  function getApproved(uint256 id) external view returns (address) {
    require(id < _programCounter);
    return _approved[id];
  }

  function isApprovedForAll(address tokenOwner, address operator) external view returns (bool) {
    return _approvedForAll[tokenOwner][operator];
  }

  function ownerOf(uint256 id) external view returns (address) {
    address tokenOwner = _tokenOwners[id];
    require(tokenOwner != address(0));
    return tokenOwner;
  }

  function safeTransferFrom(address from, address to, uint256 id) external {
    transferFrom(from, to, id);
    invokeReceiver(from, to, id, new bytes(0));
  }

  function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) external {
    transferFrom(from, to, id);
    invokeReceiver(from, to, id, data);
  }

  function setApprovalForAll(address operator, bool approved) external {
    _approvedForAll[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function transferFrom(address from, address to, uint256 id) public {
    require(from == _tokenOwners[id]);
    require(to != address(0));
    require(msg.sender == from || _approvedForAll[from][msg.sender] || msg.sender == _approved[id]);
    _balances[from]--;
    _balances[to]++;
    _tokenOwners[id] = to;
    delete _approved[id];
    emit Transfer(from, to, id);
  }

  // ERC721Metadata

  function name() external pure returns (string memory) {
    return "Degenerate Computer";
  }

  function symbol() external pure returns (string memory) {
    return "DGNCMP";
  }

  function tokenURI(uint256 id) external view returns (string memory) {
    require(id < _programCounter);
    return string(abi.encodePacked("ipfs://", _metadata[id]));
  }
}
