// SPDX-License-Identifier: MIT
// Created by Mohammadsepehr (Sepehr) Karimiziarani
// Portfolio: http://sepehr.people.ua.edu/portfolio
pragma solidity ^0.8.0;

// Custom ERC20 token
contract Token {
    // Token metadata
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Constructor function to initialize the token
    constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    uint256 _totalSupply
    ) {
    // Set the token metadata
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    totalSupply = _totalSupply;

    // Give the entire supply of tokens to the msg.sender
    balanceOf[msg.sender] = totalSupply;
    }

    // Mapping to store the balance of each address
    mapping(address => uint256) public balanceOf;

    event Transfer(address from, address to, uint256 value);

    // Function to transfer tokens to another address
    function transfer(address _to, uint256 _value) public returns (bool) {
        // Reject transfers to the zero address
        require(_to != address(0), "Cannot transfer to zero address");

        // Check that the sender has enough balance to make the transfer
        require(_value <= balanceOf[msg.sender], "Insufficient balance");

        // Subtract the value from the sender's balance and add it to the recipient's balance
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;

        // Emit the Transfer event
        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}

// Crowdfunding contract
contract Crowdfund is Token {
    // Funding goal in units of the token
    uint256 public fundingGoal;

    // Current amount of funds raised
    uint256 public fundsRaised;

    // Flag to indicate if the goal has been reached
    bool public goalReached;

    // Set to true when refund period has started
    bool public refundPeriod;

    // Constructor function to initialize the crowdfund contract
    constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals,
    uint256 _totalSupply,
    uint256 _fundingGoal) 
    
    Token(_name, _symbol, _decimals, _totalSupply) {
    // Set the funding goal
    fundingGoal = _fundingGoal;
    // Initialize the balance of msg.sender
    balanceOf[msg.sender] = _totalSupply;
    }


    // Modifier to check if the refund period has started
    modifier refundAllowed() {
        require(refundPeriod, "Refund period has not started yet");
        _;
    }

    // Modifier to check if the refund period has not started
    modifier refundForbid() {
        require(!refundPeriod, "Refund period has already started yet");
        _;
    }

    // Modifier to check if the funding goal has been reached
    modifier goalNotReached() {
        require(!goalReached, "Funding goal has already been reached");
        _;
    }

    // Function to contribute to the crowdfund campaign
    function contribute() public payable goalNotReached refundForbid {
    // Check that the contribution is greater than 0
    require(msg.value > 0, "Contribution should be greater than 0");

    // Transfer the contribution amount to the contract in the form of the custom token
    Token.transfer(address(this), msg.value);
    
    // Add the contribution amount to the total funds raised
    fundsRaised = fundsRaised + msg.value;

    // Check if the funding goal has been reached
    if (fundsRaised >= fundingGoal) {
        goalReached = true;
    }
}





    // Function to start the refund period
    function startRefundPeriod() public {
        // Check that the funding goal has not been reached
        require(!goalReached, "Cannot start refund period because funding goal has been reached");

        // Set the refund period flag to true
        refundPeriod = true;
    }

    event Refund(address contributor, uint256 value);
    // Function to refund a contributor
    function refund(address payable _contributor) public refundAllowed {
        // Check that the msg.sender is the contributor
        require(msg.sender == _contributor, "msg.sender is not the contributor");
        // Check that the contributor has a balance of the custom token in the contract
        require(balanceOf[_contributor] > 0, "Contirbutor has no balance to refund");

        // Store the amount to be refunded
        uint256 refundAmount = balanceOf[_contributor];

        // Subtract the refund amount from the contributor's balance
        balanceOf[_contributor] = 0;

        // Emit the Refund event
        emit Refund(_contributor, refundAmount);

        // Send the refund amount to the contributor
        payable (msg.sender).transfer(refundAmount);
    }

}

