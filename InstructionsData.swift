import SwiftUI

struct InstructionsData {
    static let instructions: [String] = [
        "Welcome to Binary Count!",
        "In our daily lives, we're accustomed to counting using the decimal system, where we start from 1 and increment by 1 until we reach 9. \nWhen we exceed 9, we change the rightmost digit to 0 and add 1 to the left, allowing us to continue counting.",
        "Computers, however, use a binary system consisting of only two digits: 0 and 1. \nIn binary, we count similarly, but instead of moving to the next digit after 9, we move after 1. \nThe binary sequence goes 0, 1, 10, 11, 100, and so on.",
        "Unlike the decimal system, where each digit's place represents a power of 10, in binary, each digit's place represents a power of 2. \nFrom right to left, the places represent 1, 2, 4, 8, 16, and so forth.",
        "Now, let's explore an interesting aspect of binary counting that involves using our fingers. \nIn the decimal system, we can count up to 10 using our fingers. \nWith binary, however, each finger represents a power of 2. \nThat means we can count up to 1023 using only our 10 fingers!",
        "Let's start with raising your right hand with thumb on the right side. \nTry opening only your thumb.",
        "That's 1 in binary! Now try to add 1 to it",
        "That's 2! Now let's try to make 7 using your fingers",
        "Perfect! Now you can play and practice your binary counting by making the numbers that will be shown on the screen. \nIf ready, raise and open both hands with the back of your hand facing the screen!",
    ]  
    static var instructionCount: Int {
        instructions.count
    }
}
