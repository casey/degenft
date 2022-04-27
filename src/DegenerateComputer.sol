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
import "src/ERC2981.sol";
import "src/ERC721.sol";
import "src/ERC721Metadata.sol";
import "src/ERC721TokenReceiver.sol";

contract DegenerateComputer is ERC165, ERC2981, ERC721, ERC721Metadata {
  address private _root;
  mapping(address => mapping(address => bool)) private _approvedForAll;
  mapping(address => uint256) private _balances;
  mapping(uint256 => address) private _owners;
  mapping(uint256 => address) private _approved;
  mapping(uint256 => string) private _metadata;
  uint256 private _programCounter;

  modifier sudo() {
    require(msg.sender == _root);
    _;
  }

  constructor() {
    _root = msg.sender;
  }

  function chroot(address newRoot) external sudo {
    _root = newRoot;
  }

  function compile(string calldata metadata) external sudo {
    uint256 id = _programCounter++;
    _metadata[id] = metadata;
    _balances[_root]++;
    _owners[id] = _root;
    emit Transfer(address(0), _root, id);
    invokeReceiver(address(0), _root, id, new bytes(0));
  }

  function programCounter() external view returns (uint256) {
    return _programCounter;
  }

  function recompile(string calldata metadata, uint256 id) external sudo {
    require(_owners[id] == _root);
    _metadata[id] = metadata;
  }

  function root() external view returns (address) {
    return _root;
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
    // ERC165, ERC2981, ERC721, and ERC721Metadata
    return id == 0x01ffc9a7 || id == 0x2a55205a || id == 0x80ac58cd || id == 0x5b5e139f;
  }

  // ERC2981

  function royaltyInfo(uint256, uint256 price) external view returns (address, uint256) {
    return (_root, price * 10 / 100);
  }

  // ERC721

  function approve(address spender, uint256 id) external {
    address owner = _owners[id];
    require(msg.sender == owner || _approvedForAll[owner][msg.sender]);
    _approved[id] = spender;
    emit Approval(owner, spender, id);
  }

  function balanceOf(address owner) external view returns (uint256) {
    require(owner != address(0));
    return _balances[owner];
  }

  function getApproved(uint256 id) external view returns (address) {
    require(id < _programCounter);
    return _approved[id];
  }

  function isApprovedForAll(address owner, address operator) external view returns (bool) {
    return _approvedForAll[owner][operator];
  }

  function ownerOf(uint256 id) external view returns (address) {
    address owner = _owners[id];
    require(owner != address(0));
    return owner;
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
    require(from == _owners[id]);
    require(to != address(0));
    require(msg.sender == from || _approvedForAll[from][msg.sender] || msg.sender == _approved[id]);
    _balances[from]--;
    _balances[to]++;
    _owners[id] = to;
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
