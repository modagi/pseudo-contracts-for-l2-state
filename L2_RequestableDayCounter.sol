contract L2_RequestableDayCounter {
    bool public isOnL2;
    uint256 public day;
    uint256 public lastIncreasedTime;
    address public l1_requestableDayCounter;
    
    function increaseDay() external {
        require(
            isOnL2,
            "not entered"
        );
        require(
            lastIncreasedTime + 1 days >= block.timestamp,
            "too early"
        );
        
        day++
        
        lastIncreasedTime = block.timestamp;
    }
    
    function processEnter(uint256 l1_day) external {
        require(
            !isOnL2,
            "day is already entered"
        );
        
        // only OVM_L2CrossDomainMessenger contract can call this function
        require(
            msg.sender == OVM_L2CrossDomainMessenger,
            "invalid call"
        );
        
        // only L1_RequestableDayCounter contract can call this function in L1 side
        require(
            getCrossDomainMessenger().xDomainMessageSender() == l1_requestableDayCounter,
            "invalid call"
        );
        
        day = l1_day;
        lastIncreasedTime = block.timestamp;
        isOnL2 = true;
    }
    
    function exit() external {
        require(
            isOnL2,
            "day is already entered"
        );
        
        // send exit message to OVM_L2CrossDomainMessenger
        sendExitMessage();
        
        isOnL2 = false;
    }
}