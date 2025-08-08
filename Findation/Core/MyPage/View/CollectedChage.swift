import SwiftUI

struct CollectedChangeView: View {
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
    
    private func TodayDate() {
        currentDate = Date()
    }
    
    private func dateFor(day: Int) -> Date? {
        var comps = calendar.dateComponents([.year, .month], from: currentDate)
        comps.day = day
        return calendar.date(from: comps)
    }
    
    private func isToday(day: Int) -> Bool {
        guard let d = dateFor(day: day) else { return false }
        return calendar.isDate(d, inSameDayAs: Date())
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
                VStack(spacing: 0 ) {
                    
                    ZStack{
                    
                    HStack {
                        Button {
                            changeMonth(by: -1)
                        } label: {
                            Image(systemName: "arrowtriangle.left.fill")
                                .foregroundStyle(.primary)
                                .padding(.leading, 136)
                        }
                        
                        
                        Text(CalendarHelper.currentMonthText(from: currentDate))
                            .font(.body)
                            .foregroundColor(.black)
                        
                        
                        Button {
                            changeMonth(by: 1)
                        } label: {
                            Image(systemName: "arrowtriangle.right.fill")
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        Button {
                            TodayDate()
                        } label : {
                            Text("오늘")
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .foregroundColor(Color.blue)
                                .frame(width: 40, height: 22)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(11)
                            
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
                    
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
                                ZStack {
                                    Text("\(day)")
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.gray.opacity(0.3))
                                        .clipShape(Circle())
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .frame(width: 40, height: 40)
                                        .opacity(isToday(day: day) ? 1 : 0)
                                )
                            }
                        }
                    }
                    .padding(.bottom, 43)
                    
                    Spacer(minLength: 0)
                }
                .padding(.top, 17)
                .frame(width: 353, height: numRows == 6 ? 390 : 350)
                .background(Color.white)
                .cornerRadius(10)
                .frame(maxHeight: .infinity, alignment: .top)
                .animation(nil, value: numRows)
                
            }
            
        }
        
    }
    
}
#Preview {
    CollectedChangeView()
}


