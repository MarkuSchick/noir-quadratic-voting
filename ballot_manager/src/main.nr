use dep::std;

global CANDIDATE_COUNT = 5;
global VOTER_COUNT = 2;

fn main(
    commitments: [Field; VOTER_COUNT], // public commitments for each voter
    secrets: [Field; VOTER_COUNT], // Each user's ballot secret
    all_votes: [u32; VOTER_COUNT * CANDIDATE_COUNT] //Flattened array of user's votes. Votes are adjacent for each user
) -> pub [u32; CANDIDATE_COUNT] { 
    constrain check_commitments(commitments, secrets, all_votes).all(|a| a);
    let result = sum_votes(all_votes);
    result
}

fn calculate_ballot_commitment(votes: [u32; CANDIDATE_COUNT], secret: Field) -> Field {
    let mut transcript = [0; CANDIDATE_COUNT + 1];
    transcript[CANDIDATE_COUNT] = secret;
    
    for i in 0..CANDIDATE_COUNT {
        transcript[i] = votes[i] as Field;
    }

    std::hash::pedersen(transcript)[0]
}

fn sum_votes(votes: [u32; CANDIDATE_COUNT * VOTER_COUNT]) -> [u32; CANDIDATE_COUNT] {
    let mut totals = [0; CANDIDATE_COUNT];
    for i in 0..VOTER_COUNT {
        for j in 0..CANDIDATE_COUNT {
            totals[j] = totals[j] + votes[i * CANDIDATE_COUNT + j];
        }
    }
    totals
}

fn check_commitments(
    commitments: [Field; VOTER_COUNT], 
    secrets: [Field; VOTER_COUNT], 
    all_votes: [u32; VOTER_COUNT * CANDIDATE_COUNT]) -> [bool; VOTER_COUNT] {

    let mut result: [bool; VOTER_COUNT] = [false; VOTER_COUNT];
    for i in 0..VOTER_COUNT {
        let mut votes = [0 as u32; CANDIDATE_COUNT];
        for j in 0..CANDIDATE_COUNT {
            votes[j] = all_votes[i * CANDIDATE_COUNT + j];
        };
        result[i] = commitments[i] == calculate_ballot_commitment(votes, secrets[i]);
    }
    result
} 

#[test]
fn test_sum_votes() {
    let mut votes_of_voters = [0; CANDIDATE_COUNT * VOTER_COUNT];
    constrain sum_votes(votes_of_voters) == [0; CANDIDATE_COUNT];

    votes_of_voters = [1; CANDIDATE_COUNT * VOTER_COUNT];
    let votes_per_candidate: u32 = VOTER_COUNT as u32;
    constrain sum_votes(votes_of_voters) == [votes_per_candidate; CANDIDATE_COUNT];
}

#[test]
fn test_check_commitments() {
    let all_votes = [1; CANDIDATE_COUNT * VOTER_COUNT];
    let secrets = [0; VOTER_COUNT];
    let mut commitments = [0; VOTER_COUNT];

    let all_votes_slice = [1; CANDIDATE_COUNT];
    for i in 0..VOTER_COUNT {
        commitments[i] = calculate_ballot_commitment(all_votes_slice, secrets[i]);
    }

    constrain check_commitments(commitments, secrets, all_votes).all(|a| a);
}