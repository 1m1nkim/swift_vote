import SwiftUI

struct StrawDrawingView: View {
    @State private var totalPeople: Int = 6 // 총원 n명
    @State private var pickCount: Int = 2   // 뽑을 사람 m명
    @State private var names: [String] = []
    @State private var straws: [Straw] = []
    @State private var winners: [Straw] = []
    @State private var isDrawing: Bool = false
    @State private var showNameInput: Bool = false
    @State private var showResult: Bool = false
    @State private var currentStraw: Straw?
    @State private var showStrawAnimation: Bool = false
    @State private var showAlert: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("제비뽑기 게임")
                .font(.largeTitle)
                .padding()

            // 총원 설정
            Stepper("총원: \(totalPeople)명", value: $totalPeople, in: (pickCount + 1)...20)
                .padding(.horizontal)
                .disabled(isDrawing) // 게임 중에는 비활성화

            // 뽑을 인원 설정
            Stepper("뽑을 인원: \(pickCount)명", value: $pickCount, in: 1...(totalPeople - 1))
                .padding(.horizontal)
                .disabled(isDrawing) // 게임 중에는 비활성화

            // 이름 입력 여부 선택
            Toggle("이름 입력하기", isOn: $showNameInput)
                .padding(.horizontal)
                .disabled(isDrawing) // 게임 중에는 비활성화

            // 이름 입력 창 (스크롤 가능하도록 수정)
            if showNameInput {
                ScrollView {
                    VStack {
                        ForEach(0..<totalPeople, id: \.self) { index in
                            TextField("이름 \(index + 1)", text: Binding(
                                get: { names.indices.contains(index) ? names[index] : "" },
                                set: { newValue in
                                    if names.indices.contains(index) {
                                        names[index] = newValue
                                    } else {
                                        names.append(newValue)
                                    }
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .disabled(isDrawing) // 게임 중에는 비활성화
                        }
                    }
                }
                .frame(height: 200) // 스크롤 뷰의 높이 제한
            }

            // 제비뽑기 시작 버튼
            if !isDrawing {
                Button(action: {
                    startDrawing()
                }) {
                    Text("제비뽑기 시작")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            } else {
                // 제비 표시
                ScrollView(.horizontal, showsIndicators: true) { // 스크롤 인디케이터 표시
                    HStack(spacing: 10) {
                        ForEach(straws) { straw in
                            StrawView(straw: straw)
                                .onTapGesture {
                                    drawStraw(straw: straw)
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // 가운데 정렬
                    .padding()
                }
            }

            // 선택된 당첨자들 표시
            if !winners.isEmpty {
                Text("당첨자들:")
                    .font(.headline)
                ForEach(winners) { straw in
                    Text(straw.name)
                        .font(.title2)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding()
        // 결과 표시용 모달 뷰
        .overlay(
            Group {
                if showResult, let straw = currentStraw {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                        VStack(spacing: 20) {
                            Text(straw.isWinner ? "당첨!" : "꽝!")
                                .font(.largeTitle)
                                .foregroundColor(straw.isWinner ? .yellow : .red)
                                .padding()
                            Text(straw.name)
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .frame(width: 200, height: 200)
                        .background(straw.isWinner ? Color.green : Color.gray)
                        .cornerRadius(20)
                        .scaleEffect(showStrawAnimation ? 1.0 : 0.1)
                        .animation(.spring(), value: showStrawAnimation)
                        .onAppear {
                            withAnimation {
                                showStrawAnimation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showResult = false
                                    showStrawAnimation = false
                                }
                                if straw.isWinner {
                                    if winners.count == pickCount {
                                        showAlert = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        )
        // Alert 표시
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("당첨 완료"),
                message: Text("당첨자:\n" + winners.map { $0.name }.joined(separator: "\n")),
                primaryButton: .default(Text("새 게임")) {
                    resetGame()
                },
                secondaryButton: .default(Text("다시시작")) {
                    restartDrawing()
                }
            )
        }
    }

    private func startDrawing() {
        isDrawing = true
        winners = []
        generateStraws()
    }

    private func generateStraws() {
        // 이름 설정
        if !showNameInput || names.count < totalPeople {
            names = (1...totalPeople).map { "사람 \($0)" }
        }

        // 당첨자 수 설정
        let winnerCount = pickCount

        // 당첨자 결정
        let winnerIndices = Array(0..<totalPeople).shuffled().prefix(winnerCount)

        // 제비 생성
        straws = names.enumerated().map { index, name in
            Straw(id: UUID(), name: name, isSelected: false, isWinner: winnerIndices.contains(index))
        }

        // 제비 섞기
        straws.shuffle()
    }

    private func drawStraw(straw: Straw) {
        guard !straw.isSelected else { return }

        // 선택된 제비 업데이트
        if let index = straws.firstIndex(where: { $0.id == straw.id }) {
            straws[index].isSelected = true
            currentStraw = straws[index]
            showResult = true

            // 당첨일 경우에만 winners에 추가
            if straws[index].isWinner {
                winners.append(straws[index])

                // 당첨 인원이 모두 뽑혔는지 확인
                if winners.count == pickCount {
                    // 모든 당첨자가 뽑혔을 때 Alert는 showResult 이후에 처리
                }
            }
        }
    }

    private func resetGame() {
        // 모든 상태 초기화
        isDrawing = false
        straws = []
        winners = []
        names = []
    }

    private func restartDrawing() {
        // 기존 설정 유지하면서 게임 초기화
        isDrawing = true
        winners = []
        generateStraws()
    }
}

struct Straw: Identifiable {
    let id: UUID
    let name: String
    var isSelected: Bool
    let isWinner: Bool
}

struct StrawView: View {
    var straw: Straw

    var body: some View {
        VStack {
            // 제비 아이콘은 선택된 경우에만 표시
            if straw.isSelected {
                Image(systemName: straw.isWinner ? "star.fill" : "xmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(straw.isWinner ? .yellow : .red)
                    .padding(.bottom, 5)
                    .scaleEffect(1.5)
                    .animation(.easeInOut(duration: 0.3), value: straw.isSelected)
            }

            // 제비 표시
            Rectangle()
                .fill(straw.isSelected ? Color.gray : Color.brown)
                .frame(width: 30, height: straw.isSelected ? 100 : 150)
                .cornerRadius(5)
                .padding(5)
        }
    }
}

struct StrawDrawingView_Previews: PreviewProvider {
    static var previews: some View {
        StrawDrawingView()
    }
}
