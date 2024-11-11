import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Combine

struct MainView: View {
    @Namespace var animation

    // 모든 버튼의 데이터를 하나의 배열로 통합
    let boxData: [(String, String, AnyView)] = [
        ("투표 만들기", "makeVote", AnyView(CreatePollView(animation: Namespace().wrappedValue))),
        ("투표하기", "doVote", AnyView(DoVoteView(animation: Namespace().wrappedValue))),
        ("룰렛 게임", "roullet", AnyView(RouletteView())),
        ("제비뽑기", "straw", AnyView(StrawDrawingView())),
        ("박스 5", "box5", AnyView(DummyView())),
        ("박스 6", "box6", AnyView(DummyView()))
    ]

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    // 앱 로고 추가 (MainView의 맨 위)
                    Image("appLogo") // 로고 이미지를 프로젝트에 추가하고, 이름을 'appLogo'로 설정하세요.
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width * 0.5) // 화면 너비의 50%
                        .padding(.top, 20)

                    ScrollView {
                        let columns = [GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(boxData, id: \.0) { box in
                                NavigationLink(destination: box.2) {
                                    VStack {
                                        Image(box.1)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: geometry.size.width * 0.2) // 화면 너비의 20%

                                        Text(box.0)
                                            .font(.headline)
                                            .padding(.top, 5)
                                    }
                                    .padding()
                                    .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4) // 박스 크기 조정
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}

struct DummyView: View {
    var body: some View {
        Text("더미 화면")
            .font(.largeTitle)
    }
}
