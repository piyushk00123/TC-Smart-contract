// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "hardhat/console.sol";
contract Shamir {

    struct Point {
        int x;
        int y;
    }

    struct FractionStruct {
        int256 num;
        int256 den;
    }

    function gcd(int256 a, int256 b) public pure returns (int256) {
        while (b != 0) {
            int256 temp = b;
            b = a % b;
            a = temp;
        }
        return a;
    }

    function reduceFraction(FractionStruct memory f) public pure returns (FractionStruct memory) {
        int256 gcdValue = gcd(f.num, f.den);
        f.num /= gcdValue;
        f.den /= gcdValue;
        return f;
    }

    function multiply(FractionStruct memory f1, FractionStruct memory f2) public pure returns (FractionStruct memory) {
        FractionStruct memory temp = FractionStruct(f1.num * f2.num, f1.den * f2.den);
        return reduceFraction(temp);
    }

    function add(FractionStruct memory f1, FractionStruct memory f2) public pure returns (FractionStruct memory) {
        FractionStruct memory temp = FractionStruct(
            f1.num * f2.den + f1.den * f2.num,
            f1.den * f2.den
        );
        return reduceFraction(temp);
    }
    
    function calculateY(int x, int[] memory poly) public pure returns (int y) {
        // Initializing y
        y = 0;
        int temp = 1;
 
        // Iterating through the array
        for (uint256 i = 0; i < poly.length; i++) {
            int coeff = poly[i];
 
            // Computing the value of y
            y = y + (coeff * temp);
            temp = temp * x;
        }
    }

    function generateShares(int S, uint N, uint256 K) public view returns (Point[] memory){
        Point[] memory points= new Point[](N);
        //console.log(K);
        int[] memory poly = new int[](K);
        poly[0] = S;
 
        for (uint256 j = 1; j < K; ++j) {
            int256 p = 0;
            while (p == 0) {
                p = int256(uint256(keccak256(abi.encodePacked(block.timestamp, j)))) % 1000000007; // Use block timestamp and j as a source of randomness
            }
            poly[j] = p;
        }
        for (uint j = 1; j <= N; ++j) {
            uint x = j;
            int y = calculateY(int(x), poly);
            // console.logInt(x);
            // console.logInt(y);
            uint256 piy=uint256(j-1);
            points[piy].x=int(x);
            points[piy].y = y;
        }
        return points;
        // for(uint i=0;i<N;i++)
        // {
        //     console.logInt(points[i].x);
        //     console.logInt(points[i].y);
        // }
    }

    function reconstructSecret(int256[] memory x, int256[] memory y, uint256 M, uint256 threshold) public pure returns (int256) {
        FractionStruct memory ans = FractionStruct(0, 1);
        require(M>=threshold, "Threshold number of shares not provided!");
        // Loop to iterate through the given points
        for (uint256 i = 0; i < M; ++i) {
            // Initializing the fraction
            FractionStruct memory l = FractionStruct(y[i], 1);

            for (uint256 j = 0; j < M; ++j) {
                // Computing the lagrange terms
                if (i != j) {
                    FractionStruct memory temp = FractionStruct(-x[j], x[i] - x[j]);
                    l = multiply(l, temp);
                }
            }

            ans = add(ans, l);
        }

        // Return the secret
        return ans.num;
    }

    
}
