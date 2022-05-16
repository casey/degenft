// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

import "../src/DegenerateComputer.sol";
import "ds-test/test.sol";
import "test/HEVM.sol";
import "test/NonERC721TokenReceiver.sol";

contract ContractTest is DSTest, ERC721TokenReceiver {
  DegenerateComputer computer;
  HEVM vm = HEVM(DSTest.HEVM_ADDRESS);
  address owner;

  function setUp() public {
    computer = new DegenerateComputer();
    owner = address(this);
  }

  // Implement ERC721TokenReceiver so address(this) can receive tokens
  function onERC721Received(address, address, uint256, bytes calldata) public pure returns(bytes4) {
    return ERC721TokenReceiver.onERC721Received.selector;
  }

  // Other

  function testProgramCounter() public {
    assertEq(computer.programCounter(), 0);
    computer.compile("");
    assertEq(computer.programCounter(), 1);
  }

  // ERC165

  function testDoesNotSupportUnsupportedInterfaces() public view {
    require(!computer.supportsInterface(0x00000000));
  }

  function testSupportsERC165Interface() public view {
    require(computer.supportsInterface(bytes4(keccak256('supportsInterface(bytes4)'))));
  }

  function testSupportsERC173Interface() public view {
    require(computer.supportsInterface(
      bytes4(keccak256('owner()')) ^
      bytes4(keccak256('transferOwnership(address)'))
    ));
  }

  function testSupportsERC2981Interface() public view {
    require(computer.supportsInterface(bytes4(keccak256("royaltyInfo(uint256,uint256)"))));
  }

  function testSupportsERC721Interface() public view {
    require(computer.supportsInterface(
      bytes4(keccak256('balanceOf(address)')) ^
      bytes4(keccak256('ownerOf(uint256)')) ^
      bytes4(keccak256('approve(address,uint256)')) ^
      bytes4(keccak256('getApproved(uint256)')) ^
      bytes4(keccak256('setApprovalForAll(address,bool)')) ^
      bytes4(keccak256('isApprovedForAll(address,address)')) ^
      bytes4(keccak256('transferFrom(address,address,uint256)')) ^
      bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
      bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
    ));
  }

  function testSupportsERC721MetadataInterface() public view {
    require(computer.supportsInterface(
      bytes4(keccak256('name()')) ^
      bytes4(keccak256('symbol()')) ^
      bytes4(keccak256('tokenURI(uint256)'))
    ));
  }

  // ERC173

  function testOwner() public {
    assertEq(computer.owner(), owner);
    computer.transferOwnership(address(1));
    assertEq(computer.owner(), address(1));
  }

  function testTransferOwnership() public {
    computer.compile("");
    computer.recompile("a", 0);
    computer.transferOwnership(address(1));

    vm.expectRevert();
    computer.compile("");
    vm.expectRevert();
    computer.recompile("b", 0);
    vm.expectRevert();
    computer.transferOwnership(owner);

    vm.startPrank(address(1));
    computer.compile("");
    computer.recompile("c", 1);
    computer.transferOwnership(owner);
    vm.stopPrank();

    computer.compile("");
    computer.recompile("a", 2);
    computer.transferOwnership(address(1));
  }

  // ERC2981

  function testRoyaltyFor0() public {
    (address to, uint256 amount) = computer.royaltyInfo(0, 0);
    assertEq(to, owner);
    assertEq(amount, 0);
  }

  function testRoyaltyFor100() public {
    (address to, uint256 amount) = computer.royaltyInfo(0, 100);
    assertEq(to, owner);
    assertEq(amount, 10);
  }

  function testRoyaltyFor1000() public {
    (address to, uint256 amount) = computer.royaltyInfo(0, 1000);
    assertEq(to, owner);
    assertEq(amount, 100);
  }

  function testRoyaltyInfoRoundsDown() public {
    (address to, uint256 amount) = computer.royaltyInfo(0, 101);
    assertEq(to, owner);
    assertEq(amount, 10);
  }

  // ERC721

  function testApproveAllowsOwner() public {
    computer.compile("");

    computer.approve(address(1), 0);

    vm.prank(address(2));
    vm.expectRevert();
    computer.approve(address(3), 0);
  }

  function testApproveAllowsAuthorizedOperator() public {
    computer.compile("");

    computer.approve(address(1), 0);

    vm.prank(address(2));
    vm.expectRevert();
    computer.approve(address(3), 0);

    computer.setApprovalForAll(address(2), true);

    vm.prank(address(2));
    computer.approve(address(3), 0);
  }

  function testOwnerMayTransfer() public {
    computer.compile("");
    vm.prank(address(1));
    vm.expectRevert();
    computer.transferFrom(owner, address(1), 0);
    computer.transferFrom(owner, address(1), 0);
  }

  function testApprovedMayTransfer() public {
    computer.compile("");
    vm.prank(address(1));
    vm.expectRevert();
    computer.transferFrom(owner, address(1), 0);
    computer.approve(address(1), 0);
    vm.prank(address(1));
    computer.transferFrom(owner, address(1), 0);
  }

  function testApprovedForAllMayTransfer() public {
    computer.compile("");
    vm.prank(address(1));
    vm.expectRevert();
    computer.transferFrom(owner, address(1), 0);
    computer.setApprovalForAll(address(1), true);
    vm.prank(address(1));
    computer.transferFrom(owner, address(1), 0);
    computer.setApprovalForAll(address(1), false);
  }

  function testGetApproved() public {
    computer.compile("");
    assertEq(computer.getApproved(0), address(0));
    computer.approve(address(1), 0);
    assertEq(computer.getApproved(0), address(1));
  }

  function testGetApprovedRequiresValidTokenID() public {
    vm.expectRevert();
    computer.getApproved(0);
    computer.compile("");
    computer.getApproved(0);
  }

  function testIsApprovedForAll() public {
    assertTrue(!computer.isApprovedForAll(owner, address(1)));
    computer.setApprovalForAll(address(1), true);
    assertTrue(computer.isApprovedForAll(owner, address(1)));
    computer.setApprovalForAll(address(1), false);
    assertTrue(!computer.isApprovedForAll(owner, address(1)));
  }

  function testBalanceIncrementsAfterCompile() public {
    assertEq(computer.balanceOf(owner), 0);
    computer.compile("");
    assertEq(computer.balanceOf(owner), 1);
  }

  function testBalanceOfRequiresNonzeroAddress() public {
    computer.balanceOf(address(1));
    vm.expectRevert();
    computer.balanceOf(address(0));
  }

  function testTransferUpdatesBalance() public {
    computer.compile("");
    assertEq(computer.balanceOf(owner), 1);
    assertEq(computer.balanceOf(address(1)), 0);
    computer.transferFrom(owner, address(1), 0);
    assertEq(computer.balanceOf(owner), 0);
    assertEq(computer.balanceOf(address(1)), 1);
  }

  function testOnlyOwnerMayTransfer() public {
    computer.compile("");
    computer.transferFrom(owner, address(1), 0);
    vm.expectRevert();
    computer.transferFrom(address(1), owner, 0);
  }

  function testSecondOwnerMayTransfer() public {
    computer.compile("");
    computer.transferFrom(owner, address(1), 0);
    vm.prank(address(1));
    computer.transferFrom(address(1), address(2), 0);
  }

  function testOwnerOf() public {
    computer.compile("");
    assertEq(computer.ownerOf(0), owner);
    computer.transferFrom(owner, address(1), 0);
    assertEq(computer.ownerOf(0), address(1));
  }

  function testOwnerOfThrowsIfOwnerIsZeroAddress() public {
    vm.expectRevert();
    computer.ownerOf(0);
  }

  function testTransferRequiresFromAddressIsOwner() public {
    computer.compile("");
    vm.expectRevert();
    computer.transferFrom(address(1), address(2), 0);
    computer.transferFrom(owner, address(1), 0);
    vm.prank(address(1));
    computer.transferFrom(address(1), address(2), 0);
  }

  function testTransferRequiresNonzeroToAddress() public {
    computer.compile("");
    vm.expectRevert();
    computer.transferFrom(owner, address(0), 0);
    computer.transferFrom(owner, address(1), 0);
  }

  function testTransferRequiresValidID() public {
    vm.expectRevert();
    computer.transferFrom(owner, address(1), 0);
    computer.compile("");
    computer.transferFrom(owner, address(1), 0);
  }

  function testTransferDoesNotRequireValidReceiver() public {
    computer.compile("");
    NonERC721TokenReceiver receiver = new NonERC721TokenReceiver();
    vm.expectRevert();
    computer.safeTransferFrom(owner, address(receiver), 0);
    computer.transferFrom(owner, address(receiver), 0);
  }

  function testTransferDeletesApproval() public {
    computer.compile("");
    assertEq(computer.getApproved(0), address(0));
    computer.approve(address(1), 0);
    assertEq(computer.getApproved(0), address(1));
    computer.transferFrom(owner, address(1), 0);
    assertEq(computer.getApproved(0), address(0));
  }

  // ERC721Metadata

  function testNameIsCorrect() public {
    assertEq(computer.name(), "Degenerate Computer");
  }

  function testSymbolIsCorrect() public {
    assertEq(computer.symbol(), "DGNCMP");
  }

  function testCompileSetsTokenURI() public {
    vm.expectRevert();
    computer.tokenURI(0);
    computer.compile("foo");
    assertEq(computer.tokenURI(0), "ipfs://foo");
  }

  function testRecompilChangesTokenURI() public {
    vm.expectRevert();
    computer.tokenURI(0);
    computer.compile("foo");
    assertEq(computer.tokenURI(0), "ipfs://foo");
    computer.recompile("bar", 0);
    assertEq(computer.tokenURI(0), "ipfs://bar");
  }
}
