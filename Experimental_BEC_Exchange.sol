pragma solidity ^0.4.9;


contract bec {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Reward(address indexed _miner, uint256 _value, bool _current);

    uint256 public totalSupply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    uint256 minedBlock = 0;
    address satoshi;

    string public name = "BitEtherCoin";
    uint8  public decimals = 8;
    string public symbol = "BEC";

    // Initial reward per Ethereum Block is 2,
    // for 25 block it gives same reward as for Bitcoin first era (2 * 25 == 50)
    //
    //                   2.00000000
    uint256 rewardBase = 200000000;

    uint256  eraSize =    5250000;
    uint256  startBlock = 1892;

    function BitEtherCoin() {
        satoshi = msg.sender;
    }

    // Mining Operations

    function claim() returns (uint256) {
        var (eraId, eraBlock, reward, prevReward) = getEra();
        if (minedBlock >= block.number) {
            Reward(block.coinbase, reward, false);
        } else if (eraId > 0 && eraId < 30) {
            uint256 unclaimed = getUnclaimed(eraBlock, minedBlock, block.number, prevReward, reward);

            if (reward > 0) {
                balances[msg.sender] += reward;
                totalSupply += reward;
            }

            if (unclaimed > 0) {
                balances[satoshi] += unclaimed;
                totalSupply += unclaimed;
            }

            minedBlock = block.number;
            Reward(msg.sender, reward, true);
        }
        return reward;
    }

    // returns:
    //  uint256 - era id
    //  uint256 - era start block
    //  uint256 - current era reward
    //  uint256 - previous era reward
    function getEra() returns(uint256, uint256, uint256, uint256) {
        return getEraForBlock(block.number);
    }

    // returns:
    //  uint256 - era id
    //  uint256 - era start block
    //  uint256 - current era reward
    //  uint256 - previous era reward
    function getEraForBlock(uint256 _block) returns(uint256, uint256, uint256, uint256) {
        if (_block < startBlock) {
            return (0, 0, 0, 0);
        }
        uint256 coinBlock = _block - startBlock;
        uint256 eraNumber = coinBlock / eraSize;
        uint256 eraId = eraNumber + 1;
        uint256 eraStart = startBlock + eraNumber * eraSize;
        if (eraNumber > 0) {
            // for eraNumber = 1 (second era) it should be rewardBase
            uint256 rewardPrevious = rewardBase / (2 ** (eraNumber - 1));
            uint256 reward = rewardPrevious / 2;
            return (eraId, eraStart, reward, rewardPrevious);
        } else {
            return (eraId, eraStart, rewardBase, 0);
        }
    }

    // parameters:
    //  uint256 _eraBlock     - start block for current era
    //  uint256 _blockMined   - last mined block
    //  uint256 _blockNumber  - current block
    //  uint256 _rewardPrev   - reward for previous era (or 0)
    //  uint256 _reward       - reward for current era
    function getUnclaimed(uint256 _eraBlock, uint256 _blockMined, uint256 _blockNumber,
                          uint256 _rewardPrev, uint256 _reward) returns(uint256) {
        uint256 unclaimed = 0;
        if (_blockMined >= startBlock) {
            if (_blockMined < _eraBlock) {
                // some blocks are from previous era
                unclaimed = (_eraBlock - _blockMined) * _rewardPrev;
                if (_blockNumber > _eraBlock) {
                    unclaimed += (_blockNumber - _eraBlock - 1) * _reward;
                }
            } else {
                // all block are from current era
                unclaimed = (_blockNumber - _blockMined - 1) * _reward;
            }
        } else if (_blockNumber > _eraBlock) {
            unclaimed = (_blockNumber - _eraBlock - 1) * _reward;
        }
        return unclaimed;
    }

    // Token Interface

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to]        += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to]   += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Other

    function () {
        throw;
    }
}











/*                     CONTRACT I WISH TO CREATE              */

contract ExperimentalExchange {
    
    address owner;
    address public contract_addr='0x0F8eCa799fDbE0906Ed98c00F84B7B9324b7b3b8';
    uint public price_per_BEC=50000000000000000;   //0.5 ETC per each BEC
    uint this_ETC_balance=0;
    uint this_BEC_balance=0;
    
    
    uint bec_WEI=10000000;
    uint etc_WEI=1000000000000000000;
    
    
    bool public debugging;
    bool locked;
    
    modifier onlyunlocked { if (!locked) _; }
    modifier onlydebug { if (debugging) _; }
    modifier onlyowner { if (msg.sender == owner) _; }
    
    
    

    function ExperimentalExchange() {
        owner = msg.sender;
    }
    
    function() payable onlyunlocked{
        if((msg.value>0)&&((msg.value / (price_per_BEC / bec_WEI)) <= this_BEC_balance))
        {
            uint amount = msg.value / (price_per_BEC / bec_WEI);
            bec tmp = bec(contract_addr);
            if(tmp.transfer(msg.sender, amount))
            {
                this_BEC_balance-=amount;
            }
            else
            {
                throw;
            }
        }
        else
        {
            throw;
        }
    }
    
    function sell_my_BEC(uint amount) onlyunlocked
    {
        if((amount>0)&&((amount*(price_per_BEC / bec_WEI)) <= this_ETC_balance))
        {
            uint reward = amount*(price_per_BEC / bec_WEI);
            bec tmp = bec(contract_addr);
            if((reward>0)&&(tmp.transferFrom(msg.sender, address(this), amount)))
            {
                this_BEC_balance+=amount;
                if(msg.sender.send(reward))
                {
                    this_ETC_balance-=reward;
                }
            }
            else
            {
                throw;
            }
        }
        else
        {
            throw;
        }
    }
     
    function donate_BEC(uint amount) onlyunlocked
    {
        if(amount>0)
        {
            bec tmp = bec(contract_addr);
            if(tmp.transferFrom(msg.sender, address(this), amount))
            {
                this_BEC_balance+=amount;
            }
        }
    }
     
    function donate_ETC() payable onlyunlocked
    {
        if(msg.value>=0)
        {
            this_ETC_balance+=msg.value;
        }
    }
    
    function change_price(uint _price) onlyowner{
        price_per_BEC= _price;
    }
    
    function change_contract_address(address _address) onlyowner{
        contract_addr= _address;
    }
    
    function kill_contract() onlyowner {
                
        bec tmp = bec(contract_addr);
        if(tmp.transfer(owner, this_BEC_balance))
        {
        }
        suicide(owner);
    }
    
    
    
    /*              DEBUGGING           */
    
    
    
    
    function debug_withdraw_ETC() onlyowner onlydebug {
        if(owner.send(this_ETC_balance))
        {
            this_ETC_balance=0;
        }
        else
        {
            throw;
        }
    }
    
    function debug_withdraw_BEC() onlyowner onlydebug {
        
        bec tmp = bec(contract_addr);
        if(tmp.transfer(owner, this_BEC_balance))
        {
            this_BEC_balance=0;
        }
        else
        {
            throw;
        }
    }
    
    function debug_lock_contract(uint new_balance) onlyowner onlydebug {
        
        //FUNCTION TO DISABLE DEPOSITS
        locked=true;
    }
    
    function debug_unlock_contract(uint new_balance) onlyowner onlydebug {
        
        //FUNCTION TO ENABLE DEPOSITS
        locked=false;
    }
    
    function debug_turn_off() onlyowner onlydebug {
        debugging=false;
    }
    
}
