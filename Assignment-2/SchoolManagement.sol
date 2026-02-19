// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./OmoboiToken.sol";

contract SchoolManagement {

    OmoboiToken public token;
    address public owner;

    struct Student {
        string name;
        uint level;
        bool hasPaid;
        uint paymentTimestamp;
    }

    struct Staff {
        string name;
        uint salary;
        bool hasBeenPaid;
        uint paymentTimestamp;// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../ERC20Token/OmoboiToken.sol";

contract SchoolManagement {

    OmoboiToken public token;
    address public owner;

    struct Student {
        string name;
        uint level;
        bool hasPaid;
        uint paymentTimestamp;
    }

    struct Staff {
        string name;
        uint salary;
        bool hasBeenPaid;
        uint paymentTimestamp;
    }

    mapping(address => Student) public students;
    mapping(address => Staff) public staffs;

    mapping(uint => uint) public levelFee;

    address[] public staffList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _tokenAddress) {
        token = OmoboiToken(_tokenAddress);
        owner = msg.sender;

        levelFee[100] = 100 ether;
        levelFee[200] = 200 ether;
        levelFee[300] = 300 ether;
        levelFee[400] = 400 ether;
    }

    function registerStudent(string memory _name, uint _level) external {
        require(_level >= 100 && _level <= 400, "Invalid level");
        require(levelFee[_level] > 0, "Fee not set");

        uint fee = levelFee[_level];

        bool success = token.transferFrom(msg.sender, address(this), fee);
        require(success, "Payment failed");

        students[msg.sender] = Student(
            _name,
            _level,
            true,
            block.timestamp
        );
    }

    function registerStaff(address _staffAddress, string memory _name, uint _salary) external onlyOwner {
        staffs[_staffAddress] = Staff(
            _name,
            _salary,
            false,
            0
        );

        staffList.push(_staffAddress);
    }

    function payStaff(address _staffAddress) external onlyOwner {
        Staff storage staff = staffs[_staffAddress];

        require(staff.salary > 0, "Staff not found");

        bool success = token.transfer(_staffAddress, staff.salary);
        require(success, "Payment failed");

        staff.hasBeenPaid = true;
        staff.paymentTimestamp = block.timestamp;
    }

    function getStudent(address _student) external view returns (Student memory) {
        return students[_student];
    }

    function getAllStaff() external view returns (address[] memory) {
        return staffList;
    }
}

    }

    mapping(address => Student) public students;
    mapping(address => Staff) public staffs;

    mapping(uint => uint) public levelFee;

    address[] public staffList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _tokenAddress) {
        token = OmoboiToken(_tokenAddress);
        owner = msg.sender;

        levelFee[100] = 100 ether;
        levelFee[200] = 200 ether;
        levelFee[300] = 300 ether;
        levelFee[400] = 400 ether;
    }

    function registerStudent(string memory _name, uint _level) external {
        require(_level >= 100 && _level <= 400, "Invalid level");
        require(levelFee[_level] > 0, "Fee not set");

        uint fee = levelFee[_level];

        bool success = token.transferFrom(msg.sender, address(this), fee);
        require(success, "Payment failed");

        students[msg.sender] = Student(
            _name,
            _level,
            true,
            block.timestamp
        );
    }

    function registerStaff(address _staffAddress, string memory _name, uint _salary) external onlyOwner {
        staffs[_staffAddress] = Staff(
            _name,
            _salary,
            false,
            0
        );

        staffList.push(_staffAddress);
    }

    function payStaff(address _staffAddress) external onlyOwner {
        Staff storage staff = staffs[_staffAddress];

        require(staff.salary > 0, "Staff not found");

        bool success = token.transfer(_staffAddress, staff.salary);
        require(success, "Payment failed");

        staff.hasBeenPaid = true;
        staff.paymentTimestamp = block.timestamp;
    }

    function getStudent(address _student) external view returns (Student memory) {
        return students[_student];
    }

    function getAllStaff() external view returns (address[] memory) {
        return staffList;
    }
}
