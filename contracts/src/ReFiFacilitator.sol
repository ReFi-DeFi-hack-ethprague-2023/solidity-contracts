// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

// import {IFacilitator} from "./interfaces/IFacilitator.sol";
import {IGhoToken} from "./interfaces/IGhoToken.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// ReFi Facilitator contract that has the authority to mint GHO tokens based on messaged received from the Cosmos outpost
// Acts as the FACILITATOR_MANAGER & BUCKET_MANAGER for the GHO token
contract ReFiFacilitator is Ownable {
  address public ghoToken; // GhoToken contract address
  address public aaveGovernance; // Aave Governance contract address
  address public bridge; // Axelar bridge calls

  constructor(address _ghoToken, address _aaveGovernance, address _bridge) {
    ghoToken = _ghoToken;
    aaveGovernance = _aaveGovernance;
    bridge = _bridge;
  }

  modifier onlyBridge() {
    require(msg.sender == bridge, "only bridge can call");
    _;
  }

<<<<<<< HEAD
  function onAxelarGmp(address recipient, uint256 amount) external onlyBridge {
    // decode payload here
    //address recipient = address(0); // any values rn
    //uint256 amount = 0;
=======
  function setBridgeAddress(address _bridge) external onlyOwner {
    bridge = _bridge;
  }
>>>>>>> b3bb369 (update params, ownable, constructor)

  function onAxelarGmp(address recipient, uint amount) external onlyBridge {
    // Call gho token mint function
    IGhoToken(ghoToken).mint(recipient, amount);
  }

  function updateMintLimit(uint128 newLimit) external {
    // Check call by aave governance
    require(
      msg.sender == aaveGovernance,
      "only aave governance allowed to set" // this could be a modifier TODO
    );
    // Validate the new limit as this doesn't happen in the gho token contract
    require(newLimit > 0, "INVALID_MINT_LIMIT"); // ?? do we want to allow 0 limit ?

    // Call the gho token contract as the BUCKET_MANAGER to set the new limit
    IGhoToken(ghoToken).setFacilitatorBucketCapacity(address(this), newLimit);
  }

  function addFaciliator(
    uint128 mintLimit,
    string calldata label
  ) external onlyOwner {
    // Call the gho token contract as the FACILITATOR_MANAGER to set this contract as a facilitator of the token
    IGhoToken(ghoToken).addFacilitator(address(this), label, mintLimit);
  }
}
