import SwiftUI

struct ManualEntryView: View {
    @Binding var entries: [[String: String]]
    @State private var currentEntry: [String: String] = [:]
    
    // Error messages
    @State private var nameError: String?
    @State private var phoneError: String?
    @State private var affiliationError: String?
    @State private var studentIdError: String?
    
    var body: some View {
        VStack {
            // 입력 필드들
            TextField("소속", text: Binding(
                get: { currentEntry["소속"] ?? "" },
                set: { currentEntry["소속"] = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
            if let error = affiliationError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            TextField("학번", text: Binding(
                get: { currentEntry["학번"] ?? "" },
                set: { currentEntry["학번"] = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
            if let error = studentIdError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            TextField("이름", text: Binding(
                get: { currentEntry["이름"] ?? "" },
                set: { currentEntry["이름"] = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
            if let error = nameError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            TextField("전화번호", text: Binding(
                get: { currentEntry["전화번호"] ?? "" },
                set: { currentEntry["전화번호"] = $0 }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            
            if let error = phoneError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            // 항목 추가 버튼
            Button(action: {
                if validateEntry() {
                    // 전화번호 변환 적용
                    if let phone = currentEntry["전화번호"] {
                        currentEntry["전화번호"] = formatPhoneNumber(phone)
                    }
                    entries.append(currentEntry)
                    currentEntry = [:]
                    // Clear error messages
                    nameError = nil
                    phoneError = nil
                    affiliationError = nil
                    studentIdError = nil
                }
            }) {
                Text("항목 추가")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // 총 인원 수
            Text("총 \(entries.count)명")
                .padding(.top)
            
            // 구분선
            Divider().padding(.vertical)
            
            // 항목 리스트
            if entries.isEmpty {
                Text("추가된 항목이 없습니다.")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(entries.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("이름: \(entries[index]["이름"] ?? "")")
                                    Text("학번: \(entries[index]["학번"] ?? "")")
                                    Text("소속: \(entries[index]["소속"] ?? "")")
                                    Text("전화번호: \(entries[index]["전화번호"] ?? "")")
                                }
                                Spacer()
                                Button(action: {
                                    // 항목 삭제
                                    entries.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 200) // 리스트 높이 조정
            }
        }
    }
    
    func validateEntry() -> Bool {
        var isValid = true
        
        // Validate "이름"
        let name = currentEntry["이름"] ?? ""
        if name.isEmpty || name.count > 10 {
            nameError = "이름은 1~10자리여야 합니다."
            isValid = false
        } else {
            nameError = nil
        }
        
        // Validate "전화번호"
        let phone = currentEntry["전화번호"]?.replacingOccurrences(of: "-", with: "") ?? ""
        if phone.isEmpty || phone.count != 11 || !phone.allSatisfy({ $0.isNumber }) {
            phoneError = "전화번호는 -를 제외한 11자리 숫자여야 합니다."
            isValid = false
        } else {
            phoneError = nil
        }
        
        // Validate "소속"
        let affiliation = currentEntry["소속"] ?? ""
        if !affiliation.isEmpty && (affiliation.count < 1 || affiliation.count > 20) {
            affiliationError = "소속은 1~20자리여야 합니다."
            isValid = false
        } else {
            affiliationError = nil
        }
        
        // Validate "학번"
        let studentId = currentEntry["학번"] ?? ""
        if !studentId.isEmpty && (studentId.count < 1 || studentId.count > 20) {
            studentIdError = "학번은 1~20자리여야 합니다."
            isValid = false
        } else {
            studentIdError = nil
        }
        
        return isValid
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        
        if cleanedPhoneNumber.hasPrefix("0") {
            let index = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 1)
            let formattedNumber = "+82" + cleanedPhoneNumber[index...]
            return formattedNumber
        }
        return cleanedPhoneNumber
    }
}
