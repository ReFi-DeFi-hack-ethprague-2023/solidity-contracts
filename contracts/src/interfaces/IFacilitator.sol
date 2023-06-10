// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @title IFacilitator
 * @author NaturePeg
 * @notice Interface for a Facilitator contract that has the authority to mint GHO tokens based on messaged received from the Cosmos outpost
 * @dev Acts as the FACILITATOR_MANAGER & BUCKET_MANAGER for the GHO token
 */
interface IFacilitator {
  /**
   * @dev Caller is not authorized error
   */
  error UnauthorizedCaller();

  /**
   * @dev Emitted when the Facilitator has minted new GHO based on a bridge message
   * @param recipient The address that received the minted tokens
   * @param amount The amount of tokens minted
   */
  event AssetsBridged(address indexed recipient, uint256 amount);

  /**
   * @dev Emitted when the Facilitator has burned GHO from the Facilitator contract account, emitted to indicate that the bridge has been activated
   * @param amount The amount of tokens burned
   */
  event GHOBurned(uint256 amount);

  // -------------------------------------- Functions ----------------------------------------------------------- //

  /**
   * @notice Mints new GHO tokens by calling the token contract, called upon bridge message
   * @dev Only the bridge can call this function
   * @param recipient The address to mint tokens to
   * @param amount The amount of tokens to mint
   */
  function onAxelarGmp(address recipient, uint256 amount) external;

  /**
   * @notice Transfer GHO tokens from the User to the Facilitator contract and burn them in the GHO contract
   * @dev User calls this after approving the tokens
   * @param amount The amount of tokens to burn
   */
  function burn(uint256 amount) external;

  /**
   * @notice Adds a new facilitator (itself as one) to the GHO token contract
   * @dev Only the admin can call this function; it acts in the FACILITATOR_MANAGER_ROLE for the GHO token contract
   * @param mintLimit BucketCapacity to set for the Facilitator
   * @param label The label to set for the facilitator
   */
  function addFaciliator(uint128 mintLimit, string calldata label) external;

  /**
   * @notice Update the BucketCapacity for the facilitator
   * @dev Only the admin can call this function; it acts in the BUCKET_MANAGER_ROLE for the GHO token contract
   * @param newLimit The new BucketCapacity to set
   */
  function updateMintLimit(uint128 newLimit) external;
}
