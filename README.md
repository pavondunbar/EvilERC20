# EvilERC20 Token - Comprehensive Security Research & Testing Contract

⚠️ **WARNING: EDUCATIONAL PURPOSES ONLY** ⚠️

This repository contains deliberately vulnerable and malicious smart contract code designed exclusively for security research, education, and testing purposes. **DO NOT DEPLOY THIS CONTRACT ON ANY PRODUCTION NETWORK.**

## Purpose of This Repository

This repository contains a malicious ERC20 token implementation that incorporates multiple attack vectors and deceptive behaviors. It is intended to:

1. Help security researchers understand token-based threats
2. Provide security auditors with a comprehensive reference for token vulnerabilities
3. Enable security testing in controlled environments
4. Educate developers on how to identify and mitigate token-based attacks
5. Demonstrate real-world scam tactics used by malicious actors

## Attack Vectors & Vulnerabilities (40+ Attack Vectors)

This contract intentionally implements numerous security vulnerabilities and malicious features:

### Token Ownership & Control Exploits
- Hidden admin functionality with privileged operations
- Backdoor access through secret keys
- Ability to upgrade/migrate tokens (rugpull vector)
- Hidden operator roles with elevated permissions
- **NEW**: Time-delayed admin takeover mechanism
- **NEW**: Delegated attacker role to obscure attack chain

### Token Balance Manipulation
- Direct token theft from user wallets
- Ability to blacklist any address
- Shadow balances that misrepresent actual token ownership
- Balance inflation for contract interactions (oracle manipulation)
- **NEW**: Fake approvals that appear valid but don't function
- **NEW**: Supply manipulation showing different totals to different callers

### Trading Restrictions & Honeypot Mechanisms
- Explicit honeypot mode to prevent selling
- Stealth honeypot that activates after X transactions
- Anti-bot measures that can be weaponized
- Maximum transaction/wallet limits
- **NEW**: Time-based transaction blocking

### Fee Structure Manipulation
- Asymmetric fees for buys, sells, and transfers
- Ability to change fees after launch
- Fee diversion to hidden wallets
- **NEW**: Dynamic fee scaling based on block timestamps

### Technical Attack Vectors
- Reentrancy exploits targeting DEXes and other contracts
- Fake minting that emits events but doesn't create tokens
- Self-destruct functionality with fund extraction
- Callback attacks during token operations
- **NEW**: Gas griefing attack to increase transaction costs
- **NEW**: ERC20 standard violations applied selectively
- **NEW**: Flash loan-style exploitation capability
- **NEW**: Malicious fallback function that blacklists callers

### Privacy & User Targeting
- Tracking system for all wallet interactions
- Ability to target specific users for later exploitation
- Mass operations against collected addresses
- **NEW**: Front-running attack vectors
- **NEW**: Signature-based backdoor access

### Blockchain & Transaction Manipulation
- **NEW**: Transfer event manipulation to confuse blockchain explorers 
- **NEW**: Fake burn function that appears to work but doesn't
- **NEW**: Permit function with inconsistent signature validation
- **NEW**: Block timestamp manipulation for targeted attacks

## Using This Contract for Testing

### Setting Up Test Environments

1. **Local Testing**: 
   - Deploy only on local development networks like Hardhat, Ganache, or Foundry's Anvil
   - Never deploy to testnets where other users may interact with it

2. **Integration Testing**:
   - Use this token to test DEXes, wallets, and other DApps against attack vectors
   - Create mocks for each attack type to isolate specific vulnerabilities

### Configuration Options

The contract provides extensive configuration to enable/disable specific attack vectors:

```solidity
// Basic configuration
toggleProtection(bool honeypot, bool stealthHoneypot, bool reentrancyExploit);
configureTradingParameters(bool enableTrading, uint256 maxTx, uint256 maxWallet, uint256 cooldown);
setFees(uint256 buy, uint256 sell, uint256 transferFeeAmount);

// Advanced attack configuration
configureAttackVectors(
    bool enableGasGriefing,
    bool enableTimestampManipulation,
    bool enableSupplyManipulation,
    bool enableFakeApprovals,
    bool enableERC20Violations
);
```

### Security Testing Procedure

1. **Initial Testing**:
   - Deploy token with all attack vectors disabled
   - Establish baseline functionality
   - Enable specific attack vectors one by one

2. **Integration Testing**:
   - Connect token to DEX liquidity pools
   - Test buying/selling behavior
   - Test sandwich attack potential 
   - Verify price impact calculations

3. **Protocol Defense Testing**:
   - Test protocol's token validation measures
   - Verify blacklist detection
   - Test fee manipulation detection

## Testing Specific Attack Scenarios

### Honeypot Testing
```solidity
// Enable stealth honeypot that activates after 50 transactions
token.toggleProtection(true, true, false);
token.honeypotActivationThreshold = 50;
```

### Balance Manipulation Testing
```solidity
// Test if your contract properly handles balance manipulation
// Your contract should query balances directly rather than trusting reports
uint256 reportedBalance = token.balanceOf(address);
// Verify if your contract can detect the discrepancy
```

### Gas Griefing Defense
```solidity
// Enable gas griefing attack
token.configureAttackVectors(true, false, false, false, false);
// Set transaction threshold
token._gasGriefingThreshold = 10;
// Test if your contract implements proper gas limits
```

### Flash Loan Attack Testing
```solidity
// Try to use the flash action to exploit your protocol
token.flashAction(yourContract, attackData);
// Verify if your protocol can withstand temporary balance inflation
```

## Best Practices for Defensive Development

Based on these attack vectors, implement these defenses:

1. **Token Vetting**:
   - Verify token source code for malicious patterns
   - Check contract ownership structure
   - Verify that fee structures are reasonable and fixed
   - Confirm standard ERC20 compliance

2. **Interaction Safety**:
   - Never trust token balance reports; verify with transfers
   - Implement reentrancy guards on all entry points
   - Set reasonable gas limits for token operations
   - Verify transfer success with before/after balance checks

3. **Trading Protection**:
   - Implement price impact limits
   - Add slippage protection
   - Verify transactions can be reversed
   - Test selling tokens before large purchases

## Benefits for Security Researchers & Auditors

By studying this contract, security professionals can:

1. **Comprehensive Reference**: Access a single contract containing 40+ known token attack vectors in one place
2. **Training Resource**: Train new security auditors on identifying various malicious patterns
3. **Testing Environment**: Test security tools and methodologies against known vulnerabilities
4. **Pattern Recognition**: Learn to recognize the signature patterns of malicious code
5. **Defense Development**: Develop and test defensive solutions against these attack vectors
6. **Client Education**: Demonstrate to clients what malicious code looks like
7. **Comparative Analysis**: Compare against real-world tokens to identify suspicious behaviors

## Responsible Usage Guidelines

This code is shared with the expectation of responsible usage:

- **Controlled Testing**: Only deploy on local test networks, private networks, or specialized security testing environments
- **Educational Use**: Use for educational purposes with proper context and warnings
- **Defensive Research**: Focus on developing countermeasures and detection tools
- **Disclosure**: When discussing findings based on this code, always provide proper context about its intentionally malicious nature

## Real-World Context

Unfortunately, malicious tokens are actively deployed on various blockchain networks. Understanding these attack vectors is crucial for:

- DApp developers integrating with unknown tokens
- DEX operators vetting token listings
- Wallet developers implementing safety features
- End users making informed decisions

## Technical Documentation

The contract implements a standard ERC20 interface but contains numerous malicious modifications:

- **Token Creation**: Appears to be a standard token but contains hidden supply and admin functionality
- **Transfer Logic**: Modified to include fees, restrictions, and potential blocking
- **Balance Reporting**: Manipulated to show incorrect values in certain contexts
- **Permissions System**: Complex set of roles and capabilities that enable exploits
- **External Interactions**: Dangerous patterns when interacting with other contracts

## Disclaimer

The authors of this code do not endorse or encourage any malicious use of this software. This code is provided strictly for educational and security research purposes. The repository maintainers are not responsible for any misuse of this code.

By accessing, using, or studying this code, you acknowledge that you understand its educational purpose and agree to use it responsibly.

## License

This project is licensed under MIT License - see the LICENSE file for details.

---

🔒 **Remember**: Real security comes from education, transparency, and ethical behavior. This repository exists to strengthen the ecosystem through awareness, not to enable harm.
