pragma circom 2.0.0;

// [assignment] implement a variation of mastermind from https://en.wikipedia.org/wiki/Mastermind_(board_game)#Variation as a circuit

include "../../node_modules/circomlib/circuits/comparators.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

template MastermindVariation(n) {
// Super Mastermind

    // Public inputs
    signal input pubGuess[n];
    signal input pubNumHit;
    signal input pubNumBlow;
    signal input pubSolnHash;

    // Private inputs
    signal input privSoln[n];
    signal input privSalt;

    // Output
    signal output solnHashOut;

    var guess[n];
    for (var i = 0; i < n; i += 1) {
        guess[i] = pubGuess[i];
    }

    var soln[n];
    for (var i = 0; i < n; i += 1) {
        soln[i] = privSoln[i];
    }
    
    var j = 0;
    var k = 0;
    component lessThan[2*n];
    component equalGuess[n*(n-1)/2];
    component equalSoln[n*(n-1)/2];
    var equalIdx = 0;

    // Create a constraint that the solution and guess digits are all less than 8.
    for (j=0; j<n; j++) {
        lessThan[j] = LessThan(4);
        lessThan[j].in[0] <== guess[j];
        lessThan[j].in[1] <== 8;
        lessThan[j].out === 1;
        lessThan[j+n] = LessThan(4);
        lessThan[j+n].in[0] <== soln[j];
        lessThan[j+n].in[1] <== 8;
        lessThan[j+n].out === 1;
        for (k=j+1; k<n; k++) {
            // Create a constraint that the solution and guess digits are unique. no duplication.
            equalGuess[equalIdx] = IsEqual();
            equalGuess[equalIdx].in[0] <== guess[j];
            equalGuess[equalIdx].in[1] <== guess[k];
            equalGuess[equalIdx].out === 0;
            equalSoln[equalIdx] = IsEqual();
            equalSoln[equalIdx].in[0] <== soln[j];
            equalSoln[equalIdx].in[1] <== soln[k];
            equalSoln[equalIdx].out === 0;
            equalIdx += 1;
        }
    }

    // Count hit & blow
    var hit = 0;
    var blow = 0;
    component equalHB[n*n];

    for (j=0; j<n; j++) {
        for (k=0; k<n; k++) {
            equalHB[n*j+k] = IsEqual();
            equalHB[n*j+k].in[0] <== soln[j];
            equalHB[n*j+k].in[1] <== guess[k];
            blow += equalHB[n*j+k].out;
            if (j == k) {
                hit += equalHB[n*j+k].out;
                blow -= equalHB[n*j+k].out;
            }
        }
    }

    // Create a constraint around the number of hit
    component equalHit = IsEqual();
    equalHit.in[0] <== pubNumHit;
    equalHit.in[1] <== hit;
    equalHit.out === 1;
    
    // Create a constraint around the number of blow
    component equalBlow = IsEqual();
    equalBlow.in[0] <== pubNumBlow;
    equalBlow.in[1] <== blow;
    equalBlow.out === 1;

    // Verify that the hash of the private solution matches pubSolnHash
    component poseidon = Poseidon(n+1);
    poseidon.inputs[0] <== privSalt;
    for (var i = 0; i < n; i += 1) {
        poseidon.inputs[i + 1] <==  privSoln[i];
    }

    solnHashOut <== poseidon.out;
    pubSolnHash === solnHashOut;

}

component main = MastermindVariation(5);
// 5 - Super Mastermind