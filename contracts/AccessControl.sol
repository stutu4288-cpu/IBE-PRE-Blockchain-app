// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AccessControl
 * @dev Manages file upload logs and access permissions on Ethereum local network (Ganache)
 */
contract AccessControl {

    struct FileRecord {
        string fileId;
        string fileName;
        string ownerName;
        string blockHash1;
        string blockHash2;
        string blockHash3;
        uint256 timestamp;
    }

    struct AccessGrant {
        string fileId;
        string userMail;
        string rdKey;
        bool isApproved;
        uint256 timestamp;
    }

    mapping(string => FileRecord) public files;
    mapping(string => mapping(string => AccessGrant)) public permissions;

    event FileUploaded(string indexed fileId, string fileName, string ownerName, uint256 timestamp);
    event AccessGranted(string indexed fileId, string indexed userMail, string rdKey, uint256 timestamp);
    event AccessRevoked(string indexed fileId, string indexed userMail, uint256 timestamp);

    function logUpload(
        string memory fileId,
        string memory fileName,
        string memory ownerName,
        string memory hash1,
        string memory hash2,
        string memory hash3
    ) public returns (bool) {
        files[fileId] = FileRecord(fileId, fileName, ownerName, hash1, hash2, hash3, block.timestamp);
        emit FileUploaded(fileId, fileName, ownerName, block.timestamp);
        return true;
    }

    function grantAccess(
        string memory fileId,
        string memory userMail,
        string memory rdKey
    ) public returns (bool) {
        permissions[fileId][userMail] = AccessGrant(fileId, userMail, rdKey, true, block.timestamp);
        emit AccessGranted(fileId, userMail, rdKey, block.timestamp);
        return true;
    }

    function checkAccess(string memory fileId, string memory userMail) public view returns (bool) {
        return permissions[fileId][userMail].isApproved;
    }
}
