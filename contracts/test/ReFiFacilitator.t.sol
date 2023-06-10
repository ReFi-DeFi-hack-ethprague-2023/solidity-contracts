// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
// import {Utils} from "forge-std/StdUtils.sol";
import {IGhoToken} from "../src/interfaces/IGhoToken.sol";
import {ReFiFacilitator} from "../src/ReFiFacilitator.sol";

contract ReFiFacilitatorTest is Test {
  // Utils internal utils;
  ReFiFacilitator facilitator;

  address ghoToken = 0x83eCdb25F2E678baEEEBC814D35Fa7528A676792;
  address aaveGovernance = address(0);
  address bridge = 0x610A34ed4F715F62faa86BA5A20a7602A63bc98a; // Axelar bridge address
  uint128 initialMintLimit = 1_000_000;

  address deployedGhoToken = 0xe7Fc68CAea4BA48Ae4d80C132A6187727a2b35eC;
  address user = address(0x1);

  event AssetsBridged(address indexed recipient, uint256 amount);
  event GHOBurned(uint256 amount);
  error UnauthorizedCaller();

  function setUp() public {
    facilitator = new ReFiFacilitator(ghoToken, aaveGovernance, bridge);

    // grantRoles to the facilitator contract from admin of the Gho token contract
    vm.startPrank(deployedGhoToken);
    AccessControl(ghoToken).grantRole(
      IGhoToken(ghoToken).FACILITATOR_MANAGER_ROLE(),
      address(facilitator)
    );
    AccessControl(ghoToken).grantRole(
      IGhoToken(ghoToken).BUCKET_MANAGER_ROLE(),
      address(facilitator)
    );
    vm.stopPrank();

    facilitator.addFaciliator(initialMintLimit, "NaturePegFacilitator");
  }

  function test_mint() public {
    vm.expectEmit(true, true, true, true);
    emit AssetsBridged(user, 100);

    uint amount = 100;
    vm.prank(bridge); // be sure to call the function from the bridge
    facilitator.onAxelarGmp(user, amount);
    assertEq(IGhoToken(ghoToken).balanceOf(address(user)), amount);
  }

  function test_revert_mintByUnauthorizedCaller() public {
    uint amount = 100;
    vm.expectRevert(UnauthorizedCaller.selector);
    facilitator.onAxelarGmp(user, amount);
  }

  function test_burn() public {
    test_mint(); // mint 100 tokens to the user

    uint256 amount = 50;

    // approve the tokens in the gho contract
    vm.startPrank(user);
    IGhoToken(ghoToken).approve(address(facilitator), amount);
    // call burn to transfer the tokens, burn & bridge the message
    vm.expectEmit(true, true, true, true);
    emit GHOBurned(50);
    facilitator.burn(amount);
    assertEq(IGhoToken(ghoToken).balanceOf(address(this)), 0);
    assertEq(IGhoToken(ghoToken).balanceOf(address(user)), 50);
  }
}
