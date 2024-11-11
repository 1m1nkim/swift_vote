import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Combine

struct DoVoteView: View {
    var animation: Namespace.ID
    
    @State private var phoneNumber: String = ""
    @State private var name: String = ""
    @State private var uniqueCode: String = ""
    @State private var verificationID: String = ""
    @State private var verificationCode: String = ""
    @State private var isCodeSent = false
    @State private var alertMessage: String = ""
    @State private var showAlert = false
    @State private var timerCount: Int = 60
    @State private var timerRunning: Bool = false
    @State private var timer: AnyCancellable?
    @State private var navigateToPollDetail = false  // 인증 완료 후 PollDetailView로 이동
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    Text("전화번호 인증")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    TextField("고유 코드 입력", text: $uniqueCode)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .frame(maxWidth: geometry.size.width * 0.9)

                    TextField("이름 입력", text: $name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .frame(maxWidth: geometry.size.width * 0.9)

                    TextField("ex)010-0000-0000", text: $phoneNumber)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.phonePad)
                        .frame(maxWidth: geometry.size.width * 0.9)

                    Button(action: {
                        sendVerificationCode()
                    }) {
                        Text("인증 코드 전송")
                            .padding()
                            .frame(maxWidth: geometry.size.width * 0.9)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    if isCodeSent {
                        TextField("인증 코드 입력", text: $verificationCode)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: geometry.size.width * 0.9)

                        Button(action: {
                            verifyCode()
                        }) {
                            Text("코드 확인")
                                .padding()
                                .frame(maxWidth: geometry.size.width * 0.9)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Text("남은 시간: \(timerCount) 초")
                            .font(.headline)
                            .padding()
                    }

                    NavigationLink(
                        destination: PollDetailView(uniqueCode: uniqueCode),
                        isActive: $navigateToPollDetail,
                        label: {
                            EmptyView()
                        }
                    )
                }
                .padding()
                .frame(width: geometry.size.width)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("인증 상태"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
    }
    
    func sendVerificationCode() {
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        let trimmedPhoneNumber = cleanedPhoneNumber.hasPrefix("0") ? String(cleanedPhoneNumber.dropFirst()) : cleanedPhoneNumber
        let formattedNumber = "+82" + trimmedPhoneNumber

        let ref = Database.database().reference()

        ref.child("polls").child(uniqueCode).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                var isUserFound = false

                if let pollData = snapshot.value as? [String: Any] {
                    for (_, userData) in pollData {
                        if let userDict = userData as? [String: Any],
                           let storedPhoneNumber = userDict["전화번호"] as? String,
                           let storedName = userDict["이름"] as? String {

                            if storedPhoneNumber == formattedNumber && storedName == name {
                                isUserFound = true
                                sendCode(to: formattedNumber)
                                break
                            }
                        }
                    }
                } else {
                    self.alertMessage = "데이터 형식이 잘못되었습니다."
                    self.showAlert = true
                }

                if !isUserFound {
                    self.alertMessage = "이름 또는 전화번호가 일치하지 않습니다."
                    self.showAlert = true
                }
            } else {
                self.alertMessage = "해당 고유 코드가 존재하지 않습니다."
                self.showAlert = true
            }
        }
    }

    func sendCode(to phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.alertMessage = "인증 코드 전송 중 오류: \(error.localizedDescription)"
                self.showAlert = true
                return
            }
            self.verificationID = verificationID ?? ""
            self.isCodeSent = true
            self.alertMessage = "인증 코드가 전송되었습니다."
            self.showAlert = true
            self.startTimer()
        }
    }

    func verifyCode() {
        guard !verificationID.isEmpty else {
            self.alertMessage = "인증 코드 전송에 실패했습니다. 다시 시도해 주세요."
            self.showAlert = true
            return
        }

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                alertMessage = "인증에 실패했습니다. 다시 시도해 주세요."
                showAlert = true
                return
            }

            // 인증이 완료되면 바로 navigateToPollDetail을 true로 설정하여 PollDetailView로 이동
            navigateToPollDetail = true
        }
    }

    func startTimer() {
        stopTimer()
        timerCount = 60
        timerRunning = true

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.timerRunning && self.timerCount > 0 {
                    self.timerCount -= 1
                } else if self.timerCount == 0 {
                    self.showAlert = true
                    self.alertMessage = "코드 유효시간이 지났습니다."
                    self.deleteUser()
                    self.stopTimer()
                }
            }
    }

    func stopTimer() {
        timerRunning = false
        timer?.cancel()
        timer = nil
    }

    func deleteUser() {
        if let user = Auth.auth().currentUser {
            user.delete { error in
                if let error = error {
                    print("사용자 삭제 중 오류 발생: \(error.localizedDescription)")
                } else {
                    print("사용자가 성공적으로 삭제되었습니다!")
                }
            }
        }
    }
}
