// Simple clicker game system
#[starknet::interface]
pub trait IClicker<T> {
    fn click(ref self: T);
    fn buy_upgrade(ref self: T);
}

#[dojo::contract]
pub mod clicker {
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo_starter::models::ClickerScore;
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ClickerClicked {
        #[key]
        pub player: ContractAddress,
        pub points_earned: u256,
        pub total_points: u256,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ClickerUpgraded {
        #[key]
        pub player: ContractAddress,
        pub new_click_power: u64,
    }

    #[abi(embed_v0)]
    impl ClickerImpl of super::IClicker<ContractState> {
        fn click(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();
            let timestamp = get_block_timestamp();

            // Get or create player score
            let mut score: ClickerScore = world.read_model(player);
            
            // Initialize if new player
            if score.click_power == 0 {
                score.click_power = 1;
            }

            // Add points based on click power
            let points_earned = score.click_power.into();
            score.points += points_earned;
            score.total_clicks += 1;
            score.last_click_time = timestamp;

            // Write updated score
            world.write_model(@score);

            // Emit event
            world.emit_event(@ClickerClicked {
                player,
                points_earned,
                total_points: score.points,
            });
        }

        fn buy_upgrade(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            let mut score: ClickerScore = world.read_model(player);

            // Cost: 100 points per upgrade level
            let upgrade_cost = (score.click_power * 100).into();
            
            // Check if player has enough points
            if score.points < upgrade_cost {
                return;
            }

            // Deduct cost and upgrade
            score.points -= upgrade_cost;
            score.click_power += 1;

            // Write updated score
            world.write_model(@score);

            // Emit event
            world.emit_event(@ClickerUpgraded {
                player,
                new_click_power: score.click_power,
            });
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"clickergame")
        }
    }
}

