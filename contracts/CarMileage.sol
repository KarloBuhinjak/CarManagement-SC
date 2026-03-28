// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract CarMileage {

    struct Record {
        uint256 mileage;
        uint256 timestamp;
        address mechanic;
    }

    mapping(string => Record[]) private records;

    event MileageAdded(string vin, uint256 mileage, address mechanic);

    function addMileage(string memory vin, uint256 mileage) public {
        require(mileage > 0, "Mileage must be greater than 0");

        Record[] storage vinRecords = records[vin];

        if (vinRecords.length > 0) {
            require(
                mileage >= vinRecords[vinRecords.length - 1].mileage,
                "Mileage cannot decrease"
            );
        }

        records[vin].push(Record({
            mileage: mileage,
            timestamp: block.timestamp,
            mechanic: msg.sender
        }));

        emit MileageAdded(vin, mileage, msg.sender);
    }

    function getRecords(string memory vin) public view returns (Record[] memory) {
        return records[vin];
    }
}