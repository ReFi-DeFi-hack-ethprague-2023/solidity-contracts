// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ReFiFacilitator} from "../src/ReFiFacilitator.sol";
import {IGhoToken} from "../src/interfaces/IGhoToken.sol";
import {GhoToken} from "../src/GhoToken.sol";

/**
 * @title FacilitatorSetup
 * @notice Script for deploying & setting up ReFiFacilitator contract
 */
contract FacilitatorSetup is Script, Test {
  function setUp() public {}

  function run() public {
    // read DEPLOYER_PRIVATE_KEY from environment variables
    uint256 deployerPrivateKey = vm.envUint("FORGE_PRIVATE_KEY"); // this addrss is set as the admin in gho token

    address aaveGovernance = address(0);
    address bridge = address(0); // Axelar bridge address
    address ghoAdmin = 0xe7Fc68CAea4BA48Ae4d80C132A6187727a2b35eC;

    uint128 initialMintLimit = 1_000_000;

    // start broadcast any transaction after this point will be submitted to chain
    vm.startBroadcast(deployerPrivateKey);

    // deploy ReFiFacilitator & Gho token
    console.log("Deploying Gho & Facilitator contract");
    GhoToken ghoToken = new GhoToken(address(ghoAdmin));
    ReFiFacilitator facilitator = new ReFiFacilitator(
      address(ghoToken),
      aaveGovernance,
      bridge
    );
    console.log("Gho token deployed at: ", address(ghoToken));
    console.log("Facilitator contract deployed at: ", address(facilitator));

    // grantRoles to the facilitator contract from admin address
    console.log("Granting right roles to the Facilitator contract");
    ghoToken.grantRole(
      IGhoToken(ghoToken).FACILITATOR_MANAGER_ROLE(),
      address(facilitator)
    );
    ghoToken.grantRole(
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
