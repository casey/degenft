// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.13;

import "../src/DegenerateComputer.sol";
import "ds-test/test.sol";

contract ContractTest is DSTest {
    DegenerateComputer computer;

    function setUp() public {
      computer = new DegenerateComputer();
    }

    function testName() public {
        assertEq(computer.name(), "Degenerate Computer");
    }

    function testToken() public {
        assertEq(computer.symbol(), "DGNCMP");
    }
}
