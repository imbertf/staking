// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract StakingContract is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    uint256 public rewardRate = 100; // Tokens per block as reward
    uint256 public lockTime = 7 seconds;
    
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 reward;
    }
    
    mapping(address => Stake) public stakes;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);

    constructor(address _stakingToken) Ownable(msg.sender) {
        require(_stakingToken != address(0), "Invalid token address");
        stakingToken = IERC20(_stakingToken);
    }

    // Fonction de staking
    function stake(uint256 _amount) external nonReentrant {
        require(_amount > 0, "Amount must be greater than 0");

        // Vérification de l'allocation de l'utilisateur pour s'assurer que le contrat peut transférer les tokens
        uint256 allowance = stakingToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Allowance is too low");

        // Check
        Stake storage userStake = stakes[msg.sender];
        if (userStake.amount > 0) {
            userStake.reward += calculateReward(msg.sender);
        }
        
        // Effects
        userStake.amount += _amount;
        userStake.startTime = block.timestamp;
        
        emit Staked(msg.sender, _amount);
        
        // Interaction : Transfert des tokens du sender vers le contrat
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
    }
    
    // Fonction pour retirer les tokens (unstake)
    function unstake() external nonReentrant {
        Stake storage userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No stake found");
        require(block.timestamp >= userStake.startTime + lockTime, "Stake is locked");
        
        // Calcul des récompenses
        uint256 reward = calculateReward(msg.sender) + userStake.reward;
        uint256 amount = userStake.amount;
        require(stakingToken.balanceOf(address(this)) >= amount + reward, "Insufficient contract balance");
        
        // Effects
        userStake.amount = 0;
        userStake.reward = 0;
        
        emit Unstaked(msg.sender, amount, reward);
        
        // Interaction : Envoi des tokens à l'utilisateur
        stakingToken.safeTransfer(msg.sender, amount);
        if (reward > 0) {
            stakingToken.safeTransfer(msg.sender, reward);
        }
    }
    
    // Fonction de calcul des récompenses
    function calculateReward(address _user) public view returns (uint256) {
        Stake memory userStake = stakes[_user];
        if (userStake.amount == 0) return 0;
        
        uint256 stakedTime = block.timestamp - userStake.startTime;
        return userStake.amount * rewardRate * (stakedTime / 1 days);
    }
    
    // Fonction pour mettre à jour le taux de récompense
    function setRewardRate(uint256 _rate) external onlyOwner {
        require(_rate > 0, "Reward rate must be greater than 0");
        rewardRate = _rate;
    }
    
    // Fonction pour ajuster le temps de lock
    function setLockTime(uint256 _lockTime) external onlyOwner {
        require(_lockTime > 0, "Lock time must be greater than 0");
        lockTime = _lockTime;
    }
}
