// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AI-Powered Trade Bot Integration
 * @dev A clean smart contract without OpenZeppelin, allowing AI bot interaction for reporting user profits.
 */
contract AIPoweredTradeBotIntegration {
    address public owner;
    address public aiBot;

    mapping(address => uint256) private userDeposits;
    mapping(address => uint256) private userProfits;

    event Deposited(address indexed user, uint256 amount);
    event ProfitReported(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event AIBotUpdated(address indexed oldBot, address indexed newBot);

    constructor(address _aiBot) {
        require(_aiBot != address(0), "AI bot address cannot be zero");
        owner = msg.sender;
        aiBot = _aiBot;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAIBot() {
        require(msg.sender == aiBot, "Not the AI bot");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        userDeposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function reportProfit(address user, uint256 amount) external onlyAIBot {
        require(userDeposits[user] > 0, "User has no deposit");
        userProfits[user] += amount;
        emit ProfitReported(user, amount);
    }

    function withdraw() external {
        uint256 total = userDeposits[msg.sender] + userProfits[msg.sender];
        require(total > 0, "Nothing to withdraw");

        userDeposits[msg.sender] = 0;
        userProfits[msg.sender] = 0;

        payable(msg.sender).transfer(total);
        emit Withdrawn(msg.sender, total);
    }

    function updateAIBot(address newBot) external onlyOwner {
        require(newBot != address(0), "Invalid address");
        emit AIBotUpdated(aiBot, newBot);
        aiBot = newBot;
    }

    function getUserInfo(address user) external view returns (uint256 depositedAmount, uint256 profitAmount) {
        return (userDeposits[user], userProfits[user]);
    }

    receive() external payable {
        require(msg.value > 0, "Must send ETH");
        userDeposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
}

