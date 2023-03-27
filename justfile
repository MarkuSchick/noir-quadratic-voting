# Use these commands to build and test the ballot manager and cast ballot contracts
check:
    cd ballot_manager && nargo check
    cd cast_ballot && nargo check

test:
    cd ballot_manager && nargo test
    cd ballot_manager && nargo test

prove:
    cd ballot_manager && nargo prove p
    cd cast_ballot && nargo prove p

verify:
    cd ballot_manager && nargo verify p
    cd cast_ballot && nargo verify p

codegen-verifier:
    cd ballot_manager && nargo codegen-verifier
    cd cast_ballot && nargo codegen-verifier

# Situational commands

compile:
    cd ballot_manager && nargo compile test
    cd cast_ballot && nargo compile test

execute:
    cd ballot_manager && nargo execute test
    cd cast_ballot && nargo execute test

preprocess:
    cd ballot_manager && nargo preprocess test
    cd ballot_manager && nargo preprocess test
