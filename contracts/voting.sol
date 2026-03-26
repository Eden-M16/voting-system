// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    address public owner;
    uint256 public electionId;
    
    struct Candidate {
        string name;
        uint votes;
    }
    
    struct ElectionData {
        string title;
        bool active;
        uint endTime;
        Candidate[] candidates;
        mapping(address => bool) voters;
    }
    
    mapping(uint => ElectionData) public elections;
    
    event Voted(uint electionId, address voter);
    event ElectionCreated(uint electionId, string title);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function createElection(string memory _title, uint _durationMinutes, string[] memory _candidateNames) external onlyOwner {
        uint id = electionId;
        ElectionData storage e = elections[id];
        
        e.title = _title;
        e.active = true;
        e.endTime = block.timestamp + (_durationMinutes * 60);
        
        for(uint i = 0; i < _candidateNames.length; i++) {
            e.candidates.push(Candidate(_candidateNames[i], 0));
        }
        
        electionId++;
        emit ElectionCreated(id, _title);
    }
    
    function vote(uint _electionId, uint _candidateIndex) external {
        ElectionData storage e = elections[_electionId];
        
        require(e.active, "Not active");
        require(block.timestamp < e.endTime, "Ended");
        require(!e.voters[msg.sender], "Voted");
        require(_candidateIndex < e.candidates.length, "Invalid");
        
        e.voters[msg.sender] = true;
        e.candidates[_candidateIndex].votes++;
        
        emit Voted(_electionId, msg.sender);
    }
    
    function endElection(uint _electionId) external onlyOwner {
        elections[_electionId].active = false;
    }
    
    function getCandidate(uint _electionId, uint _candidateIndex) external view returns (string memory name, uint votes) {
        Candidate memory c = elections[_electionId].candidates[_candidateIndex];
        return (c.name, c.votes);
    }
    
    function getElectionInfo(uint _electionId) external view returns (string memory title, bool active, uint endTime, uint candidateCount) {
        ElectionData storage e = elections[_electionId];
        return (e.title, e.active, e.endTime, e.candidates.length);
    }
    
    function hasVoted(uint _electionId, address _voter) external view returns (bool) {
        return elections[_electionId].voters[_voter];
    }
}