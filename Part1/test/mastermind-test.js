//[assignment] write your own unit test to show that your Mastermind variation circuit is working as expected

const chai = require("chai");
const path = require("path");
const { buildPoseidon } = require("circomlibjs");
const wasm_tester = require("circom_tester").wasm;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;


exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;



describe("Super Mastermind Testing", function () {

    this.timeout(10000);

    it("Test 1", async () => {
        const poseidon = await buildPoseidon();

        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");

        const INPUT_PUB = {
            "pubGuess": [1n, 2n, 3n, 4n, 7n],
            "pubNumHit": 2n,
            "pubNumBlow": 1n,       
        };
        const INPUT_PRIV = {
            "privSalt": 7n,
            "privSoln": [1n, 2n, 4n, 5n, 6n],
        };

        const salthash = poseidon.F.toObject(poseidon([INPUT_PRIV["privSalt"], ...INPUT_PRIV["privSoln"]]));

        INPUT_PUB["pubSolnHash"] = salthash;

        const INPUT = {...INPUT_PUB, ...INPUT_PRIV};
        
        const w = await circuit.calculateWitness(INPUT, true);
        await circuit.checkConstraints(w);
    });

    it("Test 2", async () => {
        const poseidon = await buildPoseidon();

        const circuit = await wasm_tester("contracts/circuits/MastermindVariation.circom");

        const INPUT_PUB = {
            "pubGuess": [1n, 2n, 3n, 4n, 7n],
            "pubNumHit": 0n,
            "pubNumBlow": 2n,       
        };
        const INPUT_PRIV = {
            "privSalt": 79423642393532402493148023758n,
            "privSoln": [0n, 5n, 4n, 7n, 6n],
        };

        const salthash = poseidon.F.toObject(poseidon([INPUT_PRIV["privSalt"], ...INPUT_PRIV["privSoln"]]));

        INPUT_PUB["pubSolnHash"] = salthash;

        const INPUT = {...INPUT_PUB, ...INPUT_PRIV};
        
        const w = await circuit.calculateWitness(INPUT, true);
        await circuit.checkConstraints(w);
    });
});
