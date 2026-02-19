
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SchoolManagement {

    struct Student {
        uint256 id;
        string name;
        uint256 level;
        address wallet;
        bool isRegistered;
        bool hasPaidFees;
        uint256 feesPaid;
        uint256 paymentTimestamp;
    }

    struct Staff {
        uint256 id;
        string name;
        string role;
        address wallet;
        bool isRegistered;
        uint256 salary;
        bool isPaid;
        uint256 lastPaidTimestamp;
    }

    mapping(uint256 => Student) public students;
    mapping(uint256 => Staff) public staffs;

    uint256 public studentCount;
    uint256 public staffCount;

    mapping(uint256 => uint256) public levelFees;

    address public owner;

    event StudentRegistered(uint256 indexed studentId, string name, uint256 level);
    event FeesPaid(uint256 indexed studentId, uint256 amount, uint256 timestamp);
    event StaffRegistered(uint256 indexed staffId, string name, string role);
    event StaffPaid(uint256 indexed staffId, uint256 amount, uint256 timestamp);

    constructor() {
        owner = msg.sender;
        levelFees[100] = 0.1 ether;
        levelFees[200] = 0.15 ether;
        levelFees[300] = 0.2 ether;
        levelFees[400] = 0.25 ether;
    }

    function registerStudent(
        string calldata _name,
        uint256 _level,
        address _wallet
    ) external {
        require(_level == 100 || _level == 200 || _level == 300 || _level == 400, "Invalid level");
        require(_wallet != address(0), "Invalid wallet address");

        studentCount++;
        uint256 newId = studentCount;

        students[newId] = Student({
            id: newId,
            name: _name,
            level: _level,
            wallet: _wallet,
            isRegistered: true,
            hasPaidFees: false,
            feesPaid: 0,
            paymentTimestamp: 0
        });

        emit StudentRegistered(newId, _name, _level);
    }

    function paySchoolFees(uint256 _studentId) external payable {
        Student storage student = students[_studentId];

        require(student.isRegistered, "Student not registered");
        require(!student.hasPaidFees, "Fees already paid");
        require(msg.value >= levelFees[student.level], "Insufficient payment");

        student.hasPaidFees = true;
        student.feesPaid = msg.value;
        student.paymentTimestamp = block.timestamp;

        emit FeesPaid(_studentId, msg.value, block.timestamp);
    }

    function getStudent(uint256 _studentId) external view returns (
        uint256 id,
        string memory name,
        uint256 level,
        address wallet,
        bool isRegistered,
        bool hasPaidFees,
        uint256 feesPaid,
        uint256 paymentTimestamp
    ) {
        Student storage student = students[_studentId];
        require(student.isRegistered, "Student not found");

        return (
            student.id,
            student.name,
            student.level,
            student.wallet,
            student.isRegistered,
            student.hasPaidFees,
            student.feesPaid,
            student.paymentTimestamp
        );
    }

    function registerStaff(
        string calldata _name,
        string calldata _role,
        address _wallet,
        uint256 _salary
    ) external {
        require(msg.sender == owner, "Only admin can register staff");
        require(_wallet != address(0), "Invalid wallet address");

        staffCount++;
        uint256 newId = staffCount;

        staffs[newId] = Staff({
            id: newId,
            name: _name,
            role: _role,
            wallet: _wallet,
            isRegistered: true,
            salary: _salary,
            isPaid: false,
            lastPaidTimestamp: 0
        });

        emit StaffRegistered(newId, _name, _role);
    }

    function payStaff(uint256 _staffId) external {
        require(msg.sender == owner, "Only admin can pay staff");

        Staff storage staff = staffs[_staffId];
        require(staff.isRegistered, "Staff not registered");
        require(address(this).balance >= staff.salary, "Contract has insufficient funds");

        staff.isPaid = true;
        staff.lastPaidTimestamp = block.timestamp;

        (bool success, ) = staff.wallet.call{value: staff.salary}("");
        require(success, "Payment failed");

        emit StaffPaid(_staffId, staff.salary, block.timestamp);
    }

    function getStaff(uint256 _staffId) external view returns (
        uint256 id,
        string memory name,
        string memory role,
        address wallet,
        bool isRegistered,
        uint256 salary,
        bool isPaid,
        uint256 lastPaidTimestamp
    ) {
        Staff storage staff = staffs[_staffId];
        require(staff.isRegistered, "Staff not found");

        return (
            staff.id,
            staff.name,
            staff.role,
            staff.wallet,
            staff.isRegistered,
            staff.salary,
            staff.isPaid,
            staff.lastPaidTimestamp
        );
    }

    function getAllStaffIds() external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](staffCount);
        for (uint256 i = 1; i <= staffCount; i++) {
            ids[i - 1] = i;
        }
        return ids;
    }

    receive() external payable {}

    fallback() external payable {}

    function withdrawFunds(uint256 _amount) external {
        require(msg.sender == owner, "Only admin");
        require(address(this).balance >= _amount, "Insufficient contract balance");

        (bool success, ) = payable(owner).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
