//
//  MyPageView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct CollectView : View{
    let weekdays : [String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private var currentMonthText: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "LLLL"
            return formatter.string(from: date)
        }
    
    private let calendar = Calendar.current  // 시스템의 달력 설정 가져옴 (양력 등)
    private let date = Date()      // 지금 현재 시각 (오늘 날짜)
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 30 //몇 월이 며칠까지 있는지..
    }
    
    private var firstWeekdayOffset: Int {  // 이번 달 1일이 무슨 요일인지 계산
        let components = calendar.dateComponents([.year, .month], from: date)
        // 오늘 날짜에서 연도와 월만 추출 (1일 만들기 위해)
        
        guard let firstOfMonth = calendar.date(from: components) else { return 0 }
        // 해당 월의 "1일" 날짜 객체 만들기
        
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        // 1일이 무슨 요일인지 숫자로 반환 (일:1 ~ 토:7)
        
        return (weekday + 5) % 7
        // 요일을 "월요일:0 ~ 일요일:6"로 바꾸기 위한 계산
    }
    
    private let columns = Array(repeating: GridItem(.fixed(40), spacing: 7), count: 7)
    // 달력을 만들기 위한 7열짜리 열 배열 정의 (월~일 총 7일)
    
    var body: some View {
        
        ZStack{
            Color.blue
            // Color. clear << 메인에서 합칠 때 윗줄 지우기
                .edgesIgnoringSafeArea(.all)
            
            
            VStack(alignment: .leading){
                HStack{
                    
                    Text("모아보기")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.top, 17)
                        .padding(.leading, 18)
                        
                    Spacer()
                    
                    Text(currentMonthText)
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding(.trailing, 23)
                        .padding(.top, 17)
                        
                    
                }
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 13))
                            .foregroundColor(.black)
                            .opacity(0.7)
                    }
                }
                .padding(.bottom, 5)
                
                LazyVGrid(columns: columns, spacing: 8) {
                    
                    ForEach(0..<(firstWeekdayOffset + daysInMonth), id: \.self) { index in
                        if index < firstWeekdayOffset {
                            Color.clear
                                .frame(width: 40, height: 40)
                        } else {
                            let day = index - firstWeekdayOffset + 1
                            Text("\(day)")
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 43)
                
            }
            .frame(width: 353, height: 350)
            .background(Color.white)
            .cornerRadius(10)
        }
        
    }
}

#Preview {
    CollectView()
}
