# Malicious ERC20 Token - Security Research & Testing Contract

⚠️ **WARNING: EDUCATIONAL PURPOSES ONLY** ⚠️

This repository contains deliberately vulnerable and malicious smart contract code designed exclusively for security research, education, and testing purposes. **DO NOT DEPLOY THIS CONTRACT ON ANY PRODUCTION NETWORK.**

## Purpose of This Repository

This repository contains a malicious ERC20 token implementation that incorporates multiple attack vectors and deceptive behaviors. It is intended to:

1. Help security researchers understand token-based threats
2. Provide security auditors with a comprehensive reference for token vulnerabilities
3. Enable security testing in controlled environments
4. Educate developers on how to identify and mitigate token-based attacks
5. Demonstrate real-world scam tactics used by malicious actors

## Attack Vectors & Vulnerabilities

This contract intentionally implements numerous security vulnerabilities and malicious features:

### Token Ownership & Control Exploits
- Hidden admin functionality with privileged operations
- Backdoor access through secret keys
- Ability to upgrade/migrate tokens (rugpull vector)
- Hidden operator roles with elevated permissions

### Token Balance Manipulation
- Direct token theft from user wallets
- Ability to blacklist any address
- Shadow balances that misrepresent actual token ownership
- Balance inflation for contract interactions (oracle manipulation)

### Trading Restrictions & Honeypot Mechanisms
- Explicit honeypot mode to prevent selling
- Stealth honeypot that activates after X transactions
- Anti-bot measures that can be weaponized
- Maximum transaction/wallet limits

### Fee Structure Manipulation
- Asymmetric fees for buys, sells, and transfers
- Ability to change fees after launch
- Fee diversion to hidden wallets

### Technical Attack Vectors
- Reentrancy exploits targeting DEXes and other contracts
- Fake minting that emits events but doesn't create tokens
- Self-destruct functionality with fund extraction
- Callback attacks during token operations

### Privacy & User Targeting
- Tracking system for all wallet interactions
- Ability to target specific users for later exploitation
- Mass operations against collected addresses

## Benefits for Security Researchers & Auditors

By studying this contract, security professionals can:

1. **Comprehensive Reference**: Access a single contract containing most known token attack vectors in one place
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
