// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFacilitator} from "./interfaces/IFacilitator.sol";
import {IGhoToken} from "./interfaces/IGhoToken.sol";

// ReFi Facilitator contract that has the authority to mint GHO tokens based on messaged received from the Cosmos outpost
// Acts as the FACILITATOR_MANAGER & BUCKET_MANAGER for the GHO token
contract ReFiFacilitator is Ownable, IFacilitator {
  address public ghoToken; // GhoToken contract address
  address public aaveGovernance; // Aave Governance contract address
  address public bridge; // Axelar bridge calls

  constructor(address _ghoToken, address _aaveGovernance, address _bridge) {
    ghoToken = _ghoToken;
    aaveGovernance = _aaveGovernance;
    bridge = _bridge;
  }

  modifier onlyBridge() {
    if (msg.sender != bridge) {
      revert UnauthorizedCaller();
    }
    _;
  }

  modifier onlyAaveGov() {
    if (msg.sender != aaveGovernance) {
      revert UnauthorizedCaller();
    }
    _;
  }

  function setBridgeAddress(address _bridge) external onlyOwner {
    bridge = _bridge;
  }

  function setAaveGov(address _aaveGovernance) external onlyOwner {
    aaveGovernance = _aaveGovernance;
  }

  function onAxelarGmp(address recipient, uint256 amount) external onlyBridge {
    IGhoToken(ghoToken).mint(recipient, amount);

    emit AssetsBridged(recipient, amount);
  }

  function burn(uint256 amount) external {
    // Transfer the tokens from the user to the facilitator contract
    IGhoToken(ghoToken).transferFrom(msg.sender, address(this), amount);
    // Call the gho token contract to burn the tokens in this account
    IGhoToken(ghoToken).burn(amount);

    emit GHOBurned(amount); // Call bridge
  }

  function updateMintLimit(uint128 newLimit) external onlyAaveGov {
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
