use starknet::ContractAddress;

// Simple clicker game models

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct ClickerScore {
    #[key]
    pub player: ContractAddress,
    pub points: u256,
    pub total_clicks: u64,
    pub click_power: u64, // Points per click
    pub last_click_time: u64,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Leaderboard {
    #[key]
    pub player: ContractAddress,
    pub rank: u64,
    pub score: u256,
}

#[cfg(test)]
mod tests {
    #[test]
    fn test_basic() {
        assert(1 == 1, 'basic test');
    }
}
