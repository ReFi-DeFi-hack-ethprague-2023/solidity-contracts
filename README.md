# LeverageReFi Solidity contracts 

## How we did it
We deploy a mock Aave GHO token contract and implement our own facilitator for it that is allowed to mint GHO tokens. The facilitator is informed by the Axelar bridge (which connects to the Cosmos chain) to mint tokens and also, upon burning, would bridge that state change back. 

In the Aave GHO token contract, the Facilitator contract is registered with its own mint limit and current mint level, which enables it to mint & burn GHO according to the IGhoToken spec.  
### Mock Aave GHO token contract 
Token contract from: https://github.com/ReFi-DeFi-hack-ethprague-2023/gho-refi-faciliator/blob/e9804c1526e47bd52a2f711ca15d758023a78d49/src/contracts/gho/GhoToken.sol

### Facilitator 
Interface:
```solidity
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
```
Full Interface here: https://github.com/ReFi-DeFi-hack-ethprague-2023/solidity-contracts/blob/main/contracts/src/interfaces/IFacilitator.sol



**Minting**
Axelar bridge calls the minting function, passing in the recipient and amount of new tokens.

**Burning**
User approves the Facilitator in the GHO token contract, then calls ```burn(amount)``` to transfer the tokens from his account to the Facilitator and burn them there. Only the Facilitator is allowed burn. Then the state change is bridged back to Cosmos. 
 

## Tests
Run the tests using 

```forge test --fork-url $FOUNDRY_RPC_URL```

Tests basic minting & burning as well as reverting on unauthorized calls. 

## Deploy 
Deploy and setup the Gho token & Facilitator contracts using 

``` forge script contracts/script/FacilitatorSetup.s.sol:FacilitatorSetup  --rpc-url $FOUNDRY_RPC_URL --private-key $FORGE_PRIVATE_KEY --broadcast --legacy ```

Then call ```setBridgeAddress(bridge)``` on the Faciliator contract passing in the bridge address. 

**Setup steps**
1. deploy GhoToken gho & set an address we control to admin 
2. call from admin 
gho.grantRole(FACILITATOR_MANAGER_ROLE, FACIL), or whichever account we set 
3. call from admin 
gho.grantRole(BUCKET_MANAGER, FACIL), or whichever account we set 
4. call from FACILITATOR_MANAGER_ROLE 
gho.addFacilitator(FACIL, label, mint_limit) => FACIL.add_faciliator()
5. now gho.mint() is only successful from our FACIL contract 
6. to change mint_limit: call from BUCKET_MANAGER
gho.setFacilitatorBucketCapacity(new_limit) => FACIL.update_mint_limit()



More information: https://hackmd.io/Nw4kEV8ATbutKhzVbGrcHA?view
