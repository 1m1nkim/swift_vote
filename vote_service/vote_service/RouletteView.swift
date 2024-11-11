import SwiftUI

struct RouletteView: View {
    @State private var rotation: Double = 0
    @State private var selectedPeopleCount: Int = 6 // 기본값을 6명으로 설정
    @State private var isSpinning: Bool = false
    @State private var isStopping: Bool = false // 룰렛이 멈추는 중인지 확인
    @State private var spinTimer: Timer? = nil // 타이머 추가

    // 최대 6명 선택
    let minPeople = 2
    let maxPeople = 6

    // 섹션 색상 배열
    let colors: [Color] = [.red, .green, .yellow, .blue, .orange, .purple]

    // 현재 선택된 인원 수에 따른 색상 배열
    var currentColors: [Color] {
        Array(colors.prefix(selectedPeopleCount))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Text("룰렛 게임")
                    .font(.largeTitle)
                    .padding()

                // 사용자 선택 영역 (사람 수)
                Picker("인원 선택", selection: $selectedPeopleCount) {
                    ForEach(minPeople...maxPeople, id: \.self) { number in
                        Text("\(number)명").tag(number)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .frame(maxWidth: geometry.size.width * 0.8)

                // 룰렛 휠
                ZStack {
                    RouletteWheelView(sections: selectedPeopleCount, colors: currentColors)
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                        .rotationEffect(.degrees(rotation))

                    // 화살표 180도 회전
                    Triangle()
                        .fill(Color.black)
                        .frame(width: 20, height: 20)
                        .rotationEffect(.degrees(180))  // 180도 회전
                        .offset(y: -geometry.size.width * 0.4 - 10)
                }
                .frame(width: geometry.size.width, height: geometry.size.width * 0.8)
                .padding()

                // 돌리기/멈추기 버튼
                Button(action: {
                    if isSpinning && !isStopping {
                        stopWheel()
                    } else if !isSpinning && !isStopping {
                        spinWheel()
                    }
                }) {
                    Text(isSpinning ? (isStopping ? "멈추는 중..." : "멈추기") : "돌리기")
                        .padding()
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .background(isStopping ? Color(UIColor.lightGray) : (isSpinning ? Color.red : Color.blue))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isStopping) // 멈추는 중일 때 버튼 비활성화
                .padding(.bottom)

                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .padding(.top)
        }
    }

    private func spinWheel() {
        isSpinning = true
        isStopping = false
        // 타이머를 사용하여 회전 값 증가
        spinTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.rotation += 15 // 회전 속도 3배 증가
        }
    }

    private func stopWheel() {
        guard isSpinning else { return }
        spinTimer?.invalidate()
        spinTimer = nil
        isStopping = true

        // 추가 회전량 계산하여 서서히 멈추기
        let extraRotation = Double.random(in: 3600...3600) 
        let finalRotation = rotation + extraRotation

        // 서서히 멈추는 애니메이션 적용
        let duration = 5.0 // 애니메이션 지속 시간 조정 (더 천천히 멈춤)
        withAnimation(Animation.easeOut(duration: duration)) {
            rotation = finalRotation
        }

        // 스핀 완료 후 상태 변경
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isSpinning = false
            self.isStopping = false
        }
    }
}

// 수정된 RouletteWheelView (숫자 제거)
struct RouletteWheelView: View {
    let sections: Int
    let colors: [Color]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<sections, id: \.self) { index in
                    ZStack {
                        // 부채꼴 그리기
                        SectorShape(
                            startAngle: Angle(degrees: Double(index) * (360.0 / Double(sections))),
                            endAngle: Angle(degrees: Double(index + 1) * (360.0 / Double(sections)))
                        )
                        .fill(colors[index % colors.count])
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}

// 부채꼴을 그리는 Shape
struct SectorShape: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)

        path.addArc(center: center,
                    radius: rect.width / 2,
                    startAngle: startAngle - Angle(degrees: 90),
                    endAngle: endAngle - Angle(degrees: 90),
                    clockwise: false)
        path.closeSubpath()

        return path
    }
}

// 삼각형 모양 (화살표)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // 꼭짓점
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // 오른쪽 아래
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // 왼쪽 아래
        path.closeSubpath()

        return path
    }
}
