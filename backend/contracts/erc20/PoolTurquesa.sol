// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";


contract PoolTurquesa is ReentrancyGuard {
    
    struct Pool {
        string name;
        address creator;
        uint fundraisingGoal;
        uint deadline;
        uint totalRaised;
        mapping(address => uint) contributions;
        mapping(address => uint) votes;
        bool fundingComplete;
    }

    struct Property {
        string name;
        uint price;
        string image;
    }

    mapping(string => Pool) public pools;
    Property[] public properties;
    
    address public owner;
    event PoolCreated(string name, uint goal, uint deadline);
    event PropertyListed(string name, uint price, string image);
    event Contribution(string poolName, address contributor, uint amount);
    event RefundClaimed(string poolName, address contributor, uint amount);
    

    constructor() {
        owner = msg.sender;
    } 
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the visionary owner can unleash this function");
        _;
}


    function createPool(string memory _name, uint _goal, uint _deadline) public onlyOwner {
        require(msg.sender == owner, "Only owner can create pools");
       // require(pools[_name].address == address(0), "Pool name already in use");
        require(_goal > 0 && _goal <= 1000000, "Fundraising goal must be between 0 and 1000000");

        Pool storage pool = pools[_name];

        pool.name = _name;
        pool.creator = msg.sender; 
        pool.fundraisingGoal = _goal;
        pool.deadline = _deadline;
        pool.totalRaised = 0;

        emit PoolCreated(_name, _goal, _deadline);
    }

    function listProperty(string memory _name, uint _price, string memory _image) public {
        require(pools[_name].fundingComplete, "Pool is not funded yet");
        require(_price > 0 && _price <= 1000000, "Property price must be between 0 and 1000000");
        require(bytes(_image).length > 0, "Property image must be provided");

        Property memory property = Property(_name, _price, _image);
        properties.push(property); 
        emit PropertyListed(_name, _price, _image);
    }

    function contribute(string memory _name, uint256 _amount) public payable nonReentrant {
        require(block.timestamp < pools[_name].deadline, "Deadline exceeded");
        require(pools[_name].fundingComplete, "Pool is already funded"); 
        require(_amount > 0, "Amount must be greater than 0");

        pools[_name].contributions[msg.sender] += _amount;
        pools[_name].totalRaised += _amount;

        emit Contribution(_name, msg.sender, _amount);

        if (pools[_name].totalRaised >= pools[_name].fundraisingGoal) {
            pools[_name].fundingComplete = true;
        }
    }

    function vote(string memory _name, uint _propIndex) public {
        require(pools[_name].contributions[msg.sender] > 0, "Only contributors can vote");
        pools[_name].votes[msg.sender] = _propIndex;
    }

    function claimRefund(string memory _name) public {
        Pool storage pool = pools[_name];
        require(block.timestamp > pool.deadline, "Deadline not reached");
        require(pools[_name].fundingComplete, "Pool was not funded");

        uint amount = pool.contributions[msg.sender];
        pool.contributions[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
        emit RefundClaimed(_name, msg.sender, amount);
    }

}