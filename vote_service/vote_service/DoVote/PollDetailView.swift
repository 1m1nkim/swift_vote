import SwiftUI
import Firebase
import FirebaseDatabase

struct PollDetailView: View {
    var uniqueCode: String
    @State private var pollTitle: String = ""
    @State private var pollDescription: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(pollTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text(pollDescription)
                    .font(.body)
                    .padding()
            }
            .padding()
            .onAppear {
                fetchPollData()
            }
        }
    }

    func fetchPollData() {
        let ref = Database.database().reference()
        ref.child("polls").child(uniqueCode).child("pollinfo").observeSingleEvent(of: .value) { snapshot in
            if let pollData = snapshot.value as? [String: Any] {
                self.pollTitle = pollData["pollTitle"] as? String ?? "제목 없음"
                self.pollDescription = pollData["pollDescription"] as? String ?? "설명 없음"
            } else {
                print("투표 데이터를 불러올 수 없습니다.")
            }
        }
    }
}
