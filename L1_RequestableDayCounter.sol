contract L1_RequestableDayCounter {
    bool public isLocked;
    uint256 public day;
    uint256 public lastIncreasedTime;
    address public l2_requestableDayCounter;
    
    function increaseDay() external {
        require(
            !isLocked,
            "day is locked"
        );
        require(
            lastIncreasedTime + 1 days >= block.timestamp,
            "too early"
        );
        
        day++
        
        lastIncreasedTime = block.timestamp;
    }
    
    function enter() external {
        require(
            !isLocked,
            "day is locked"
        );
        
        // send enter message to OVM_L1CrossDomainMessenger
        sendEnteranceMessage();
        
        isLocked = true;
    }
    
    function processExit(uint256 l2_day) external {
        require(
            isLocked,
            "day is locked"
        );
        
        // only OVM_L1CrossDomainMessenger contract can call this function
        require(
            msg.sender == OVM_L1CrossDomainMessenger,
            "invalid call"
        );
        
        // only L2_RequestableDayCounter contract can call this function in L2 side
        require(
            getCrossDomainMessenger().xDomainMessageSender() == l2_requestableDayCounter,
            "invalid call"
        );
        
        day = l2_day + dispute_period;
        lastIncreasedTime = block.timestamp;
        isLocked = false;
    }
}