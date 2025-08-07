import SwiftUI

struct ChangeCalendarView: View {
    @State private var currentDate: Date = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    private let columns = Array(repeating: GridItem(.fixed(40), spacing: 7), count: 7)
    
    struct CalendarHelper {
        static func currentMonthText(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M월"
            return formatter.string(from: date)
        }
        
        static func daysInMonth(for date: Date, calendar: Calendar = .current) -> Int {
            calendar.range(of: .day, in: .month, for: date)?.count ?? 30
        }
        
        static func firstWeekdayOffset(for date: Date, calendar: Calendar = .current) -> Int {
            let components = calendar.dateComponents([.year, .month], from: date)
            guard let firstOfMonth = calendar.date(from: components) else { return 0 }
            let weekday = calendar.component(.weekday, from: firstOfMonth)
            return (weekday + 5) % 7
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
        
    }
    
    
    var body: some View {
        
        let offset = CalendarHelper.firstWeekdayOffset(for: currentDate)
        let days = CalendarHelper.daysInMonth(for: currentDate)
        let totalCells = offset + days
        let numRows = Int(ceil(Double(totalCells) / 7.0))
        
        ZStack{
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "arrowtriangle.left.fill")
                    }
                    
                    
                    Text(CalendarHelper.currentMonthText(from: currentDate))
                        .font(.body)
                        .foregroundStyle(Color("Primary"))
                    
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "arrowtriangle.right.fill")
                    }
                }
                .padding()
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .foregroundColor(.black)
                            
                        
                    }
                }
                .padding(.bottom, 7)
                
                LazyVGrid(columns: columns, spacing: 8) {
                    

                    ForEach(0..<(offset + days), id: \.self) { index in
                        if index < offset {
                            Color.clear
                            .frame(width: 40, height: 40)
                        } else {
                            let day = index - offset + 1
                            Text("\(day)")
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.bottom, 43)
                
                Spacer(minLength: 0)
            }

            .frame(width: 353, height: numRows == 6 ? 390 : 350)
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}


#Preview {
    ChangeCalendarView()
}
