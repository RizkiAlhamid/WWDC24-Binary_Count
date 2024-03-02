import SwiftUI

struct ContentView: View {
    @Environment(ViewModel.self) private var viewModel
    
    var body: some View {
        ZStack {
            CameraView(viewModel: viewModel)
//                 For development
//                .overlay( 
//                    FingersOverlay(with: viewModel.overlayPoints)
//                        .foregroundStyle(Color(red: 173/255, green: 216/255, blue: 230/255))
//                )
            VStack {
                InstructionBox
                if viewModel.gameState == .playing {
                    Group {
                        Text("Target Number: \(viewModel.targetNumber)")
                        // For development purpose
                        //Text("Your Number: \(viewModel.currSum)") 
                    } 
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .background { 
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(Color(red: 173/255, green: 216/255, blue: 230/255))
                    }
                    .padding()
                }
                Spacer()
            }
            .overlay { 
                CorrectBadge
            }
        }
    }
    
    var InstructionBox: some View {
        Group { 
            if viewModel.gameState == .instruction || viewModel.gameState == .instructionAndTracking {
                VStack {
                    HStack {
                        if viewModel.isBackButtonAvailable() {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) { 
                                    viewModel.instructionNumber -= 1
                                }
                            }, label: {
                                Text("Back")
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(red: 70/255, green: 130/255, blue: 180/255))
                                    }
                            })                            
                        }
                        Spacer()
                        if viewModel.isNextButtonAvailable() {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.5)) { 
                                    viewModel.instructionNumber += 1
                                }
                            }, label: {
                                Text("Next")
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(Color(red: 70/255, green: 130/255, blue: 180/255))
                                    }
                            })   
                        }
                    }
                    .padding([.top, .horizontal])
                    Text("\(InstructionsData.instructions[viewModel.instructionNumber])")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .padding()
                        .padding(.bottom)
                        .padding(.bottom)
                }
                .background { 
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color(red: 173/255, green: 216/255, blue: 230/255))
                }
                .padding()
            }
        }
        
    }
    
    var CorrectBadge: some View {
        Group {
            if viewModel.isCorrect {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .imageScale(.large)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(red: 70/255, green: 130/255, blue: 180/255))
                    .frame(width: 200, height: 200)
            } 
        }
    }
}
