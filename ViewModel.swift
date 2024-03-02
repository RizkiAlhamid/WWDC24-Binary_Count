import SwiftUI

@Observable 
class ViewModel {
    enum GameState {
        case instruction
        case instructionAndTracking
        case playing
        case paused
    }
    
    var currSum = -1
    var overlayPoints: [CGPoint] = [] // For development
    var instructionNumber = 0 {
        didSet {  
            if instructionNumber == 5 {
                gameState = .instructionAndTracking
            }
        }
    }
    var targetNumber = -1
    var isCorrect = false {
        didSet {
            if isCorrect {
                gameState = .paused 
                correctEvidenceCounter = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if self.instructionNumber < InstructionsData.instructionCount - 1 {
                        self.instructionNumber += 1
                        self.gameState = .instructionAndTracking
                    } else {
                        self.gameState = .playing
                        self.changeTargetNumber()
                    }
                    self.isCorrect = false
                }
            }
        }
    }
    var gameState: GameState = .instruction
    private let evidenceCounterThreshold = 5
    private var correctEvidenceCounter = 0
    
    func processFingers(_ fingers: [Finger]) -> Int {
        if fingers.isEmpty {
            correctEvidenceCounter = 0
            currSum = -1
            return -1
        }
        var tempSum = 0;
        for finger in fingers {
            if finger.isRaised() {
                tempSum += finger.getBinaryValue()
            }
        }
        currSum = tempSum
        if targetNumber == currSum {
            //isCorrect = true
            correctEvidenceCounter += 1
        } else {
            correctEvidenceCounter = 0
            return tempSum
        }
        if correctEvidenceCounter >= evidenceCounterThreshold {
            isCorrect = true
        }
        return tempSum
    }
    
    func proceedWithPracticalInstruction(_ fingers: [Finger]) {
        if instructionNumber == 5 {
            targetNumber = 1
        } else if instructionNumber == 6 {
            targetNumber = 2
        } else if instructionNumber == 7  {
            targetNumber = 7
        } else if instructionNumber == 8 {
            targetNumber = 1023
        } else {
            targetNumber = -1
        }
        processFingers(fingers)
    }
     
    func isBackButtonAvailable() -> Bool {
        return instructionNumber > 0 && instructionNumber < 6 
    }
    func isNextButtonAvailable() -> Bool {
        return instructionNumber >= 0 && instructionNumber < 5 
    }
    func changeTargetNumber() {
        targetNumber = Finger.targetNumbersCollection.randomElement() ?? 0
    } 
}




