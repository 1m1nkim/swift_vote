import SwiftUI

struct BarChartView: View {
    // 투표수를 저장하는 배열
    let pollResults = [
        ("Option 1", 35),
        ("Option 2", 50),
        ("Option 3", 25)
    ]
    
    var body: some View {
        VStack {
            Text("투표 결과")
                .font(.title)
            
            HStack(alignment: .bottom, spacing: 15) {
                ForEach(pollResults, id: \.0) { option, votes in
                    VStack {
                        Text("\(votes)") // 투표수 표시
                            .font(.caption)
                        
                        // 막대 그래프 (투표수에 따라 높이 조정)
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 30, height: CGFloat(votes) * 2) // 높이를 투표수에 맞게 조정
                        
                        Text(option) // 옵션 이름 표시
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
    }
}

struct ContentView: View {
    var body: some View {
        BarChartView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
