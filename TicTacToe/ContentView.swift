import SwiftUI

struct ContentView: View {
    @State var moves: [Move?] = Array(repeating: nil, count: 9)
    @State var isGameBoardDisabled = false
    @State var checkFinishStatus = false

    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(0..<9) { index in
                        CellView(mark: moves[index]?.mark ?? "")
                            .onTapGesture {
                                if isGameBoardDisabled || moves[index] != nil {
                                    return
                                }
                                isGameBoardDisabled.toggle()
                                if humanPlay(at: index) { return }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if computerPlay() { return }
                                    isGameBoardDisabled.toggle()
                                }
                            }
                    }
                }
                .padding()
                .disabled(isGameBoardDisabled)
                
                Button(action: restartGame) {
                    Text("Play Again")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .opacity(checkFinishStatus ? 1 : 0)
                .disabled(!checkFinishStatus)
                .animation(.easeInOut, value: checkFinishStatus)

                Spacer()
            }
            .navigationTitle("Tic Tac Toe")
        }
    }



    func humanPlay(at index: Int) -> Bool {
        moves[index] = Move(player: .human, boardIndex: index)
        if checkWinCondition(for: .human, in: moves) {
            print("You won!")
            checkFinishStatus = true
            return true
        }
        if checkForDraw(in: moves) {
            checkFinishStatus = true
            print("Draw")
            return true
        }
        return false
    }
    
    func computerPlay() -> Bool {
        let computerPosition = determineComputerMovePosition(in: moves)
        moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
        if checkWinCondition(for: .computer, in: moves) {
            checkFinishStatus = true
            print("You lost!")
            return true
        }
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        moves.compactMap { $0 }.count == 9
    }
    
    func checkWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPatterns: [Set<Int>] = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        for pattern in winPatterns where pattern.isSubset(of: playerPositions) {
            return true
        }
        return false
    }
    
    func isCellOccupied(in moves: [Move?], forIndex: Int) -> Bool {
        moves[forIndex] != nil
    }
    
    func determineComputerMovePosition(in moves: [Move?]) -> Int {
        var movePosition = Int.random(in: 0..<9)
        while isCellOccupied(in: moves, forIndex: movePosition) {
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }

    func restartGame() {
        moves = Array(repeating: nil, count: 9)
        checkFinishStatus = false
        isGameBoardDisabled = false
    }
}

struct CellView: View {
    let mark: String
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.5)
                .frame(width: squareSize, height: squareSize)
                .cornerRadius(15)
            Image(systemName: mark)
                .resizable()
                .frame(width: markSize, height: markSize)
                .foregroundColor(.white)
        }
    }
    
    var squareSize: CGFloat { UIScreen.main.bounds.width / 3 - 15 }
    var markSize: CGFloat { squareSize / 2 }
}

enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var mark: String {
        player == .human ? "circle" : "xmark"
    }
}

#Preview {
    ContentView()
}

