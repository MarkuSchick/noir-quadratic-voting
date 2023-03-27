use dep::std;

global CANDIDATE_COUNT = 5;

fn check_within_budget(token_budget: u32, votes: [u32; CANDIDATE_COUNT]) -> bool {
    let token_spend = votes.fold(0, |acc, x| acc + x * x);
    token_spend <= token_budget
}

fn calculate_ballot_commitment(votes: [u32; CANDIDATE_COUNT], secret: Field) -> Field {
    let mut transcript = [0; CANDIDATE_COUNT + 1];
    transcript[CANDIDATE_COUNT] = secret;
    
    for i in 0..CANDIDATE_COUNT {
        transcript[i] = votes[i] as Field;
    }

    std::hash::pedersen(transcript)[0]
}

#[test]
fn test_check_within_budget() {
    // equal to threshold
    let mut votes = [5, 5, 5, 5, 0];
    constrain check_within_budget(100, votes);
    votes = [5, 5, 5, 4, 0];
    constrain check_within_budget(100, votes);
    votes = [5, 5, 5, 6, 0];
    constrain !check_within_budget(100, votes);
}

#[test]
fn test_calculate_ballot_commitment() {
    // equal to threshold
    let votes = [5, 5, 5, 5, 5];
    let secret = 0;
    constrain calculate_ballot_commitment(votes, secret) == std::hash::pedersen([5, 5, 5, 5, 5, 0])[0];
}


// performed by the user
fn main(
    token_budget: pub u32, // budget of max votes to enforce
    votes: [u32;CANDIDATE_COUNT], // ballot of user representing it's votes for each candidate
    secret: Field // for shielding the commitment from brute-force attacks
) -> pub Field{
    constrain check_within_budget(token_budget, votes); 
    calculate_ballot_commitment(votes, secret)
}

