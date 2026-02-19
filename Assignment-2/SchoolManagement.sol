// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./OmoboiToken.sol";

contract SimpleSchool {

    // Student data
    struct Student {
        address wallet;
        string name;
        uint256 level;
        bool hasPaid;
        uint256 paidAt;
    }

    // Staff data
    struct Staff {
        address wallet;
        string name;
        uint256 salary;
        bool isPaid;
        uint256 paidAt;
    }

    // Store students and staff by ID
    mapping(uint256 => Student) public students;
    mapping(uint256 => Staff) public staffs;

    // Count total students and staff
    uint256 public studentCount;
    uint256 public staffCount;

    // Token and owner
    OmoboiToken public token;
    address public owner;

    constructor(address _tokenAddress) {
        token = OmoboiToken(_tokenAddress);
        owner = msg.sender;
    }

    // 1. Register a student
    function registerStudent(string memory _name, uint256 _level) external {
        studentCount = studentCount + 1;
        
        students[studentCount].wallet = msg.sender;
        students[studentCount].name = _name;
        students[studentCount].level = _level;
        students[studentCount].hasPaid = false;
        students[studentCount].paidAt = 0;
    }

    // 2. Student pays school fees
    function payStudentFee(uint256 _id, uint256 _amount) external {
        // Get reference to student (storage = can modify)
        Student storage s = students[_id];
        
        // Check student exists and hasn't paid
        require(s.wallet != address(0), "Student not found");
        require(s.hasPaid == false, "Already paid");
        require(msg.sender == s.wallet, "Not your account");

        // Check fee amount based on level
        uint256 requiredFee = 0;
        if (s.level == 100) requiredFee = 1000 * 10**8;
        else if (s.level == 200) requiredFee = 1500 * 10**8;
        else if (s.level == 300) requiredFee = 2000 * 10**8;
        else if (s.level == 400) requiredFee = 2500 * 10**8;
        
        require(_amount >= requiredFee, "Wrong fee amount");

        // Pull tokens from student to school
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        
        // Update student record
        s.hasPaid = true;
        s.paidAt = block.timestamp;
    }

    // 3. View student details
    function getStudent(uint256 _id) external view returns (
        address wallet,
        string memory name,
        uint256 level,
        bool hasPaid,
        uint256 paidAt
    ) {
        // Get copy of student (memory = read only)
        Student memory s = students[_id];
        return (s.wallet, s.name, s.level, s.hasPaid, s.paidAt);
    }

    // 4. Register a staff (owner only)
    function registerStaff(string memory _name, uint256 _salary, address _wallet) external {
        require(msg.sender == owner, "Only owner can register staff");
        
        staffCount = staffCount + 1;
        
        staffs[staffCount].wallet = _wallet;
        staffs[staffCount].name = _name;
        staffs[staffCount].salary = _salary;
        staffs[staffCount].isPaid = false;
        staffs[staffCount].paidAt = 0;
    }

    // 5. Pay staff salary (owner only)
    function payStaff(uint256 _id) external {
        require(msg.sender == owner, "Only owner can pay staff");
        
        // Get reference to staff (storage = can modify)
        Staff storage s = staffs[_id];
        
        require(s.wallet != address(0), "Staff not found");
        require(s.isPaid == false, "Already paid");
        require(token.balanceOf(address(this)) >= s.salary, "Not enough tokens");

        // Send tokens to staff
        require(token.transfer(s.wallet, s.salary), "Transfer failed");
        
        // Update staff record
        s.isPaid = true;
        s.paidAt = block.timestamp;
    }

    // 6. View staff details
    function getStaff(uint256 _id) external view returns (
        address wallet,
        string memory name,
        uint256 salary,
        bool isPaid,
        uint256 paidAt
    ) {
        // Get copy of staff (memory = read only)
        Staff memory s = staffs[_id];
        return (s.wallet, s.name, s.salary, s.isPaid, s.paidAt);
    }
}