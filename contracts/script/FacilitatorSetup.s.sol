// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ReFiFacilitator} from "../src/ReFiFacilitator.sol";
import {IGhoToken} from "../src/interfaces/IGhoToken.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title FacilitatorSetup
 * @notice Script for deploying & setting up ReFiFacilitator contract
 */
contract FacilitatorSetup is Script, Test {
  function setUp() public {}

  function run() public {
    // read DEPLOYER_PRIVATE_KEY from environment variables
    uint256 deployerPrivateKey = vm.envUint("FORGE_PRIVATE_KEY"); // this addrss is set as the admin in gho token

    address ghoToken = 0x83eCdb25F2E678baEEEBC814D35Fa7528A676792;
    address aaveGovernance = address(0);
    address bridge = 0x610A34ed4F715F62faa86BA5A20a7602A63bc98a; // Axelar bridge address

    uint128 initialMintLimit = 1_000_000;

    // start broadcast any transaction after this point will be submitted to chain
    vm.startBroadcast(deployerPrivateKey);

    console.log("Address of Gho token: ", ghoToken);

    // deploy ReFiFacilitator
    console.log("Deploying Facilitator contract");
    ReFiFacilitator facilitator = new ReFiFacilitator(
      ghoToken,
      aaveGovernance,
      bridge
    );
    console.log("Facilitator contract deployed at: ", address(facilitator));

    // grantRoles to the facilitator contract from admin address
    console.log("Granting right roles to the Facilitator contract");
    AccessControl(ghoToken).grantRole(
      IGhoToken(ghoToken).FACILITATOR_MANAGER_ROLE(),
      address(facilitator)
    );
    AccessControl(ghoToken).grantRole(
      IGhoToken(ghoToken).BUCKET_MANAGER_ROLE(),
      address(facilitator)
    );

    // add facilitator from our FACILITATOR_MANAGER_ROLE
    console.log(
      "Adding Facilitator contract as a Facilitator for the GHO token"
    );
    facilitator.addFaciliator(initialMintLimit, "NaturePegFacilitator");
    // sanity checks
    assertEq(
      IGhoToken(ghoToken).getFacilitator(address(facilitator)).label,
      "NaturePegFacilitator"
    );
    assertEq(
      IGhoToken(ghoToken).getFacilitator(address(facilitator)).bucketCapacity,
      initialMintLimit
    );

    console.log("All done, Ready to mint!");

    // stop broadcasting transactions
    vm.stopBroadcast();
  }
}
