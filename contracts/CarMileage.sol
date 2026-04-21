// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract CarMileage is AccessControl {
    bytes32 public constant MECHANIC_ROLE = keccak256("MECHANIC_ROLE");

    struct Record {
        uint256 mileage;
        uint256 timestamp;
        address mechanic;
    }

    mapping(string => Record[]) private records;

    event MileageAdded(string vin, uint256 mileage, address mechanic);
    event MechanicAdded(address indexed mechanic);
    event MechanicRevoked(address indexed mechanic);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // ── Superadmin operations ──────────────────────────────
    function addMechanic(address mechanic) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MECHANIC_ROLE, mechanic);
        emit MechanicAdded(mechanic);
    }

    function revokeMechanic(address mechanic) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MECHANIC_ROLE, mechanic);
        emit MechanicRevoked(mechanic);
    }

    function isMechanic(address account) external view returns (bool) {
        return hasRole(MECHANIC_ROLE, account);
    }

    // ── Mechanic operations ────────────────────────────────
    function addMileage(string calldata vin, uint256 mileage)
        external
        onlyRole(MECHANIC_ROLE)
    {
        require(mileage > 0, "Mileage must be greater than 0");

        Record[] storage vinRecords = records[vin];

        if (vinRecords.length > 0) {
            require(
                mileage >= vinRecords[vinRecords.length - 1].mileage,
                "Mileage cannot decrease"
            );
        }

        vinRecords.push(Record({
            mileage: mileage,
            timestamp: block.timestamp,
            mechanic: msg.sender
        }));

        emit MileageAdded(vin, mileage, msg.sender);
    }

    // ── Public read ────────────────────────────────────────
    function getRecords(string calldata vin) external view returns (Record[] memory) {
        return records[vin];
    }
}
