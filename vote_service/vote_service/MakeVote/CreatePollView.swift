import SwiftUI
import Firebase
import FirebaseDatabase

struct CreatePollView: View {
    var animation: Namespace.ID
    @State private var step = 1
    @State private var pollTitle: String = ""
    @State private var pollDescription: String = ""
    @State private var isPublic: Bool = false
    @State private var isUsingExcel = false
    @State private var showDocumentPicker = false
    @State private var excelData: String = ""
    @State private var manualEntries: [[String: String]] = []
    @State private var isPollCreated = false
    @State private var pollURL: String = ""
    @State private var uniqueCode: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showValidationAlert = false
    @State private var numberOfCandidates: Int? = nil

    @Environment(\.presentationMode) var presentationMode

    // 입력 검증을 위한 정규식 패턴
    let titlePattern = "^[가-힣a-zA-Z\\s]{2,20}$"
    let descriptionPattern = "^[가-힣a-zA-Z\\s]{5,200}$"

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    if step == 1 {
                        Text("투표 만들기")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
    
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("투표 제목을 입력하세요", text: $pollTitle)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .frame(maxWidth: geometry.size.width * 0.9)
                            
                            HStack {
                                Text("2-20자의 한글 또는 영문")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text("(\(pollTitle.count)/20)")
                                    .font(.caption)
                                    .foregroundColor(pollTitle.count > 20 ? .red : .gray)
                            }
                            .padding(.leading)
                        }
    
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                                .frame(width: geometry.size.width * 0.9, height: 150)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: geometry.size.width * 0.9 - 8, height: 142)
                                .padding(4)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $pollDescription)
                                        .frame(width: geometry.size.width * 0.9 - 24, height: 134)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.clear)
                                    
                                    if pollDescription.isEmpty {
                                        Text("투표의 설명을 입력하세요.")
                                            .foregroundColor(Color(.systemGray3))
                                            .padding(.horizontal, 16)
                                            .padding(.top, 14)
                                            .allowsHitTesting(false)
                                    }
                                }
                                
                                HStack {
                                    Text("5-200자의 한글 또는 영문")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Spacer()
                                    
                                    Text("(\(pollDescription.count)/200)")
                                        .font(.caption)
                                        .foregroundColor(pollDescription.count > 200 ? .red : .gray)
                                }
                                .padding(.leading, 16)
                            }
                            .padding(.horizontal, 4)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("후보 수를 선택하세요")
                                .fontWeight(.medium)
                                .padding(.leading)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                                ForEach(1...10, id: \.self) { number in
                                    Button(action: {
                                        numberOfCandidates = number
                                    }) {
                                        Text("\(number)명")
                                            .frame(width: 60, height: 40)
                                            .background(numberOfCandidates == number ? Color.blue : Color(.systemGray5))
                                            .foregroundColor(numberOfCandidates == number ? .white : .black)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .frame(maxWidth: geometry.size.width * 0.9)

                        Toggle(isOn: $isPublic) {
                            Text("공개 투표 여부")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .frame(maxWidth: geometry.size.width * 0.9)
    
                        Button(action: {
                            validateAndProceed()
                        }) {
                            Text("다음")
                                .padding()
                                .frame(maxWidth: geometry.size.width * 0.9)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else if step == 2 {
                        Text("투표 인원 등록")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
    
                        Toggle(isOn: $isUsingExcel) {
                            Text("엑셀 파일로 등록하기")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .frame(maxWidth: geometry.size.width * 0.9)
    
                        if isUsingExcel {
                            Button(action: {
                                showDocumentPicker = true
                            }) {
                                Text("엑셀 파일 선택")
                                    .padding()
                                    .frame(maxWidth: geometry.size.width * 0.9)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            if !excelData.isEmpty {
                                Text("엑셀 파일이 로드되었습니다.")
                                    .foregroundColor(.green)
                            }
                        } else {
                            ManualEntryView(entries: $manualEntries)
                                .frame(maxWidth: geometry.size.width * 0.9)
                        }
    
                        Button(action: {
                            checkAndSavePoll()
                        }) {
                            Text("투표 생성하기")
                                .padding()
                                .frame(maxWidth: geometry.size.width * 0.9)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled((isUsingExcel && excelData.isEmpty) || (!isUsingExcel && manualEntries.isEmpty))
    
                        if !uniqueCode.isEmpty {
                            Text("고유 코드: \(uniqueCode)")
                                .font(.headline)
                                .padding()
                        }
                    }
                }
                .padding()
                .frame(width: geometry.size.width)
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPickerView(excelData: $excelData)
        }
        .alert("입력 확인", isPresented: $showValidationAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("투표가 생성되었습니다", isPresented: $showAlert) {
            Button("복사") {
                UIPasteboard.general.string = uniqueCode
                resetInputValues()
                presentationMode.wrappedValue.dismiss()
            }
            Button("취소", role: .cancel) {
                resetInputValues()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("고유 코드: \(uniqueCode)\n고유 코드를 복사하시겠습니까?")
        }
    }
    
    // 입력 검증 함수
    func validateAndProceed() {
        if pollTitle.isEmpty {
            alertMessage = "투표 제목을 입력해주세요."
            showValidationAlert = true
            return
        }
        
        if pollTitle.range(of: titlePattern, options: .regularExpression) == nil {
            alertMessage = "투표 제목은 2-20자의 한글 또는 영문이어야 합니다."
            showValidationAlert = true
            return
        }

        if pollDescription.range(of: descriptionPattern, options: .regularExpression) == nil {
            alertMessage = "투표 설명은 5-200자의 한글 또는 영문이어야 합니다."
            showValidationAlert = true
            return
        }

        if pollDescription.isEmpty {
            alertMessage = "투표 설명을 입력해주세요."
            showValidationAlert = true
            return
        }

        self.step = 2
    }

    func resetInputValues() {
        pollTitle = ""
        pollDescription = ""
        numberOfCandidates = 1
        isPublic = false
        isUsingExcel = false
        excelData = ""
        manualEntries = []
        uniqueCode = ""
        step = 1
    }
    
    func generateUniqueCode() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<5).map { _ in letters.randomElement()! })
    }
    
    func checkAndSavePoll() {
        let ref = Database.database().reference()
        uniqueCode = generateUniqueCode()
    
        ref.child("polls").child(uniqueCode).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.checkAndSavePoll()
            } else {
                saveDataToFirebase(with: uniqueCode)
            }
        }
    }
    
    func saveDataToFirebase(with uniqueCode: String) {
        let ref = Database.database().reference()
        var dataToSave: [[String: String]] = []
    
        let pollInfo: [String: Any] = [
            "pollTitle": pollTitle,
            "pollDescription": pollDescription,
            "numberOfCandidates": numberOfCandidates,
            "isPublic": isPublic
        ]
        ref.child("polls").child(uniqueCode).child("pollinfo").setValue(pollInfo)
    
        if isUsingExcel {
            dataToSave = parseCSVData()
        } else {
            dataToSave = manualEntries
        }
    
        for entry in dataToSave {
            var modifiedEntry = entry
            if let phone = entry["전화번호"] {
                modifiedEntry["전화번호"] = formatPhoneNumber(phone)
            }
            let uniqueID = UUID().uuidString
            ref.child("polls").child(uniqueCode).child(uniqueID).setValue(modifiedEntry)
        }
    
        showAlert = true
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    
        if cleanedPhoneNumber.hasPrefix("82") {
            return "+" + cleanedPhoneNumber
        }
    
        if cleanedPhoneNumber.hasPrefix("0") {
            let index = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 1)
            let formattedNumber = "+82" + cleanedPhoneNumber[index...]
            return formattedNumber
        }
    
        return "+82" + cleanedPhoneNumber
    }
    
    func parseCSVData() -> [[String: String]] {
        var result: [[String: String]] = []
        let rows = excelData.components(separatedBy: "\n").filter { !$0.isEmpty }
        guard let headerRow = rows.first else { return result }
        let headers = headerRow.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    
        for row in rows.dropFirst() {
            let values = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if values.count == headers.count {
                var entry: [String: String] = [:]
                for (index, header) in headers.enumerated() {
                    entry[header] = values[index]
                }
                result.append(entry)
            }
        }
        return result
    }
}
